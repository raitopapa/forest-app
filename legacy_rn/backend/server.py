from fastapi import FastAPI, HTTPException, Depends, File, UploadFile, Form
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import DuplicateKeyError
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import os
import uuid
import json
import aiofiles
from datetime import datetime, timedelta
import pandas as pd
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from bson import ObjectId
import base64
from io import BytesIO
import requests
from geopy.distance import geodesic
import asyncio

# Environment variables
from dotenv import load_dotenv
load_dotenv()

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "forest_management")

app = FastAPI(title="森林管理GIS API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB client
client = AsyncIOMotorClient(MONGO_URL)
db = client[DATABASE_NAME]

# Static files
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Pydantic models
class TreeCreate(BaseModel):
    species: str
    health: str = "healthy"
    lat: float
    lng: float
    diameter: float = 0
    height: float = 0
    notes: str = ""
    area_id: Optional[str] = None

class TreeUpdate(BaseModel):
    species: Optional[str] = None
    health: Optional[str] = None
    diameter: Optional[float] = None
    height: Optional[float] = None
    notes: Optional[str] = None

class WorkAreaCreate(BaseModel):
    name: str
    status: str = "active"
    boundary: List[List[float]]
    description: str = ""

class WorkAreaUpdate(BaseModel):
    name: Optional[str] = None
    status: Optional[str] = None
    boundary: Optional[List[List[float]]] = None
    description: Optional[str] = None

class GPSTrackCreate(BaseModel):
    name: str
    points: List[Dict[str, Any]]
    track_type: str = "path"  # path, point, polygon

class VectorLayerCreate(BaseModel):
    name: str
    layer_type: str  # point, line, polygon
    color: str
    data: List[Dict[str, Any]]
    visible: bool = True

class MeasurementCreate(BaseModel):
    start_point: Dict[str, float]
    end_point: Dict[str, float]
    distance: float
    measurement_type: str = "distance"

# Utility functions
def serialize_doc(doc):
    """Convert MongoDB document to JSON serializable format"""
    if doc is None:
        return None
    doc["_id"] = str(doc["_id"])
    return doc

def serialize_docs(docs):
    """Convert list of MongoDB documents to JSON serializable format"""
    return [serialize_doc(doc) for doc in docs]

# API Routes

@app.get("/")
async def root():
    return {"message": "森林管理GIS API", "version": "1.0.0"}

# Tree management endpoints
@app.post("/api/trees")
async def create_tree(tree: TreeCreate):
    tree_doc = {
        **tree.dict(),
        "id": str(uuid.uuid4()),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        "photos": [],
        "last_check": datetime.utcnow().isoformat()
    }
    
    result = await db.trees.insert_one(tree_doc)
    tree_doc["_id"] = str(result.inserted_id)
    return serialize_doc(tree_doc)

@app.get("/api/trees")
async def get_trees(area_id: Optional[str] = None, health: Optional[str] = None):
    query = {}
    if area_id:
        query["area_id"] = area_id
    if health:
        query["health"] = health
    
    trees = await db.trees.find(query).to_list(None)
    return serialize_docs(trees)

@app.get("/api/trees/{tree_id}")
async def get_tree(tree_id: str):
    tree = await db.trees.find_one({"id": tree_id})
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    return serialize_doc(tree)

@app.put("/api/trees/{tree_id}")
async def update_tree(tree_id: str, tree_update: TreeUpdate):
    update_data = {k: v for k, v in tree_update.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()
    
    result = await db.trees.update_one(
        {"id": tree_id}, 
        {"$set": update_data}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    tree = await db.trees.find_one({"id": tree_id})
    return serialize_doc(tree)

@app.delete("/api/trees/{tree_id}")
async def delete_tree(tree_id: str):
    result = await db.trees.delete_one({"id": tree_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Tree not found")
    return {"message": "Tree deleted successfully"}

# Work area management endpoints
@app.post("/api/work-areas")
async def create_work_area(area: WorkAreaCreate):
    area_doc = {
        **area.dict(),
        "id": str(uuid.uuid4()),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        "tree_count": 0,
        "last_visit": datetime.utcnow().isoformat()
    }
    
    result = await db.work_areas.insert_one(area_doc)
    area_doc["_id"] = str(result.inserted_id)
    return serialize_doc(area_doc)

@app.get("/api/work-areas")
async def get_work_areas():
    areas = await db.work_areas.find().to_list(None)
    
    # Update tree counts for each area
    for area in areas:
        tree_count = await db.trees.count_documents({"area_id": area["id"]})
        area["tree_count"] = tree_count
    
    return serialize_docs(areas)

@app.get("/api/work-areas/{area_id}")
async def get_work_area(area_id: str):
    area = await db.work_areas.find_one({"id": area_id})
    if not area:
        raise HTTPException(status_code=404, detail="Work area not found")
    
    # Add tree count
    tree_count = await db.trees.count_documents({"area_id": area_id})
    area["tree_count"] = tree_count
    
    return serialize_doc(area)

@app.put("/api/work-areas/{area_id}")
async def update_work_area(area_id: str, area_update: WorkAreaUpdate):
    update_data = {k: v for k, v in area_update.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()
    
    result = await db.work_areas.update_one(
        {"id": area_id}, 
        {"$set": update_data}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Work area not found")
    
    area = await db.work_areas.find_one({"id": area_id})
    return serialize_doc(area)

@app.delete("/api/work-areas/{area_id}")
async def delete_work_area(area_id: str):
    result = await db.work_areas.delete_one({"id": area_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Work area not found")
    return {"message": "Work area deleted successfully"}

# GPS tracking endpoints
@app.post("/api/gps-tracks")
async def create_gps_track(track: GPSTrackCreate):
    track_doc = {
        **track.dict(),
        "id": str(uuid.uuid4()),
        "created_at": datetime.utcnow(),
        "distance": 0
    }
    
    # Calculate total distance for path type
    if track.track_type == "path" and len(track.points) > 1:
        total_distance = 0
        for i in range(1, len(track.points)):
            p1 = track.points[i-1]
            p2 = track.points[i]
            distance = geodesic((p1["lat"], p1["lng"]), (p2["lat"], p2["lng"])).meters
            total_distance += distance
        track_doc["distance"] = total_distance
    
    result = await db.gps_tracks.insert_one(track_doc)
    track_doc["_id"] = str(result.inserted_id)
    return serialize_doc(track_doc)

@app.get("/api/gps-tracks")
async def get_gps_tracks(track_type: Optional[str] = None):
    query = {}
    if track_type:
        query["track_type"] = track_type
    
    tracks = await db.gps_tracks.find(query).to_list(None)
    return serialize_docs(tracks)

@app.delete("/api/gps-tracks/{track_id}")
async def delete_gps_track(track_id: str):
    result = await db.gps_tracks.delete_one({"id": track_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="GPS track not found")
    return {"message": "GPS track deleted successfully"}

# Vector layer endpoints
@app.post("/api/vector-layers")
async def create_vector_layer(layer: VectorLayerCreate):
    layer_doc = {
        **layer.dict(),
        "id": str(uuid.uuid4()),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    result = await db.vector_layers.insert_one(layer_doc)
    layer_doc["_id"] = str(result.inserted_id)
    return serialize_doc(layer_doc)

@app.get("/api/vector-layers")
async def get_vector_layers():
    layers = await db.vector_layers.find().to_list(None)
    return serialize_docs(layers)

@app.delete("/api/vector-layers/{layer_id}")
async def delete_vector_layer(layer_id: str):
    result = await db.vector_layers.delete_one({"id": layer_id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Vector layer not found")
    return {"message": "Vector layer deleted successfully"}

# Photo upload endpoint
@app.post("/api/trees/{tree_id}/photos")
async def upload_tree_photo(tree_id: str, file: UploadFile = File(...)):
    # Verify tree exists
    tree = await db.trees.find_one({"id": tree_id})
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")
    
    # Save uploaded file
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
    filename = f"{tree_id}_{uuid.uuid4()}.{file_extension}"
    file_path = f"uploads/{filename}"
    
    async with aiofiles.open(file_path, 'wb') as f:
        content = await file.read()
        await f.write(content)
    
    # Update tree document with photo info
    photo_info = {
        "id": str(uuid.uuid4()),
        "filename": filename,
        "file_path": file_path,
        "uploaded_at": datetime.utcnow().isoformat(),
        "size": len(content)
    }
    
    await db.trees.update_one(
        {"id": tree_id},
        {"$push": {"photos": photo_info}}
    )
    
    return photo_info

# Measurement endpoints
@app.post("/api/measurements")
async def create_measurement(measurement: MeasurementCreate):
    measurement_doc = {
        **measurement.dict(),
        "id": str(uuid.uuid4()),
        "created_at": datetime.utcnow()
    }
    
    result = await db.measurements.insert_one(measurement_doc)
    measurement_doc["_id"] = str(result.inserted_id)
    return serialize_doc(measurement_doc)

@app.get("/api/measurements")
async def get_measurements():
    measurements = await db.measurements.find().to_list(None)
    return serialize_docs(measurements)

# Analytics endpoints
@app.get("/api/analytics/summary")
async def get_analytics_summary():
    total_trees = await db.trees.count_documents({})
    healthy_trees = await db.trees.count_documents({"health": "healthy"})
    warning_trees = await db.trees.count_documents({"health": "warning"})
    critical_trees = await db.trees.count_documents({"health": "critical"})
    total_areas = await db.work_areas.count_documents({})
    total_tracks = await db.gps_tracks.count_documents({})
    total_measurements = await db.measurements.count_documents({})
    
    return {
        "total_trees": total_trees,
        "healthy_trees": healthy_trees,
        "warning_trees": warning_trees,
        "critical_trees": critical_trees,
        "total_areas": total_areas,
        "total_tracks": total_tracks,
        "total_measurements": total_measurements
    }

@app.get("/api/analytics/species-distribution")
async def get_species_distribution():
    pipeline = [
        {"$group": {"_id": "$species", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}}
    ]
    
    result = await db.trees.aggregate(pipeline).to_list(None)
    return [{"species": doc["_id"], "count": doc["count"]} for doc in result]

# Report generation endpoint
@app.get("/api/reports/generate/{report_type}")
async def generate_report(report_type: str, area_id: Optional[str] = None):
    if report_type not in ["summary", "trees", "areas", "full"]:
        raise HTTPException(status_code=400, detail="Invalid report type")
    
    # Generate PDF report
    filename = f"report_{report_type}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
    file_path = f"uploads/{filename}"
    
    doc = SimpleDocTemplate(file_path, pagesize=A4)
    story = []
    styles = getSampleStyleSheet()
    
    # Title
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        spaceAfter=30,
        alignment=1  # Center alignment
    )
    story.append(Paragraph("森林管理レポート", title_style))
    story.append(Spacer(1, 12))
    
    # Get data based on report type
    if report_type in ["summary", "full"]:
        analytics = await get_analytics_summary()
        
        data = [
            ["項目", "値"],
            ["総樹木数", str(analytics["total_trees"])],
            ["健康な樹木", str(analytics["healthy_trees"])],
            ["要注意樹木", str(analytics["warning_trees"])],
            ["作業エリア数", str(analytics["total_areas"])],
            ["GPS軌跡数", str(analytics["total_tracks"])],
        ]
        
        table = Table(data)
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 14),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black)
        ]))
        
        story.append(Paragraph("概要統計", styles['Heading2']))
        story.append(table)
        story.append(Spacer(1, 12))
    
    if report_type in ["trees", "full"]:
        trees = await get_trees(area_id=area_id)
        
        if trees:
            story.append(Paragraph("樹木一覧", styles['Heading2']))
            tree_data = [["ID", "樹種", "健康状態", "直径(cm)", "高さ(m)"]]
            
            for tree in trees[:20]:  # Limit to 20 trees for PDF
                tree_data.append([
                    tree.get("id", "")[:8],
                    tree.get("species", ""),
                    tree.get("health", ""),
                    str(tree.get("diameter", 0)),
                    str(tree.get("height", 0))
                ])
            
            tree_table = Table(tree_data)
            tree_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            
            story.append(tree_table)
    
    # Generate timestamp
    story.append(Spacer(1, 20))
    story.append(Paragraph(f"生成日時: {datetime.now().strftime('%Y年%m月%d日 %H:%M:%S')}", styles['Normal']))
    
    doc.build(story)
    
    return FileResponse(
        file_path,
        media_type="application/pdf",
        filename=filename
    )

# Data export endpoints
@app.get("/api/export/{format}")
async def export_data(format: str):
    if format not in ["json", "csv"]:
        raise HTTPException(status_code=400, detail="Invalid export format")
    
    # Get all data
    trees = await db.trees.find().to_list(None)
    areas = await db.work_areas.find().to_list(None)
    tracks = await db.gps_tracks.find().to_list(None)
    
    export_data = {
        "trees": serialize_docs(trees),
        "work_areas": serialize_docs(areas),
        "gps_tracks": serialize_docs(tracks),
        "exported_at": datetime.utcnow().isoformat()
    }
    
    filename = f"forest_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{format}"
    file_path = f"uploads/{filename}"
    
    if format == "json":
        async with aiofiles.open(file_path, 'w', encoding='utf-8') as f:
            await f.write(json.dumps(export_data, ensure_ascii=False, indent=2))
        media_type = "application/json"
    
    elif format == "csv":
        # Convert trees to CSV
        df = pd.DataFrame(export_data["trees"])
        if not df.empty:
            # Remove complex fields for CSV
            df = df.drop(columns=["photos"], errors="ignore")
        
        df.to_csv(file_path, index=False, encoding='utf-8-sig')
        media_type = "text/csv"
    
    return FileResponse(
        file_path,
        media_type=media_type,
        filename=filename
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)