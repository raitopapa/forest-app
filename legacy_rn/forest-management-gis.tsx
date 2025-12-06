import React, { useState, useEffect, useRef } from 'react';
import { MapPin, Trees, BarChart3, Settings, Plus, Search, Filter, Navigation, AlertTriangle, CheckCircle, Camera, Download, Wifi, WifiOff, Database, FileText, Compass, Ruler, Layers, Square, Circle, Minus, Trash2, Eye, EyeOff } from 'lucide-react';

const ForestManagementGIS = () => {
  const [currentPosition, setCurrentPosition] = useState(null);
  const [isTracking, setIsTracking] = useState(false);
  const [activeTab, setActiveTab] = useState('map');
  const [selectedTree, setSelectedTree] = useState(null);
  const [trackingPath, setTrackingPath] = useState([]);
  const [isOffline, setIsOffline] = useState(!navigator.onLine);
  const [offlineMapData, setOfflineMapData] = useState(null);
  const [measurements, setMeasurements] = useState([]);
  const [isCompassActive, setIsCompassActive] = useState(false);
  const [compass, setCompass] = useState(0);
  const [dataExports, setDataExports] = useState([]);
  
  // GIS機能の状態
  const [mapLayerType, setMapLayerType] = useState('standard');
  const [vectorLayers, setVectorLayers] = useState([]);
  const [drawingMode, setDrawingMode] = useState(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [currentDrawing, setCurrentDrawing] = useState([]);
  const [layerVisibility, setLayerVisibility] = useState({});
  
  const [workAreas, setWorkAreas] = useState([
    { id: 1, name: 'エリアA', status: 'active', trees: 45, lastVisit: '2025-07-20', boundary: [[35.6760, 139.6500], [35.6770, 139.6500], [35.6770, 139.6510], [35.6760, 139.6510]] },
    { id: 2, name: 'エリアB', status: 'maintenance', trees: 32, lastVisit: '2025-07-18', boundary: [[35.6750, 139.6505], [35.6760, 139.6505], [35.6760, 139.6515], [35.6750, 139.6515]] },
    { id: 3, name: 'エリアC', status: 'completed', trees: 28, lastVisit: '2025-07-25', boundary: [[35.6755, 139.6520], [35.6765, 139.6520], [35.6765, 139.6530], [35.6755, 139.6530]] }
  ]);
  
  const [trees, setTrees] = useState([
    { id: 1, species: 'スギ', health: 'healthy', lat: 35.6762, lng: 139.6503, diameter: 45, height: 15, lastCheck: '2025-07-20', photos: [], notes: '健康状態良好' },
    { id: 2, species: 'ヒノキ', health: 'warning', lat: 35.6765, lng: 139.6508, diameter: 38, height: 12, lastCheck: '2025-07-18', photos: [], notes: '枝の一部に枯れあり' },
    { id: 3, species: 'カラマツ', health: 'healthy', lat: 35.6760, lng: 139.6510, diameter: 52, height: 18, lastCheck: '2025-07-25', photos: [], notes: '成長良好' }
  ]);
  
  const watchIdRef = useRef(null);

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setCurrentPosition({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          });
        },
        (error) => console.error('位置情報の取得に失敗しました:', error)
      );
    }

    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);
    
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    const handleOrientation = (event) => {
      if (isCompassActive && event.alpha !== null) {
        setCompass(Math.round(event.alpha));
      }
    };

    if (window.DeviceOrientationEvent) {
      window.addEventListener('deviceorientation', handleOrientation);
    }

    initializeVectorLayers();

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
      window.removeEventListener('deviceorientation', handleOrientation);
    };
  }, [isCompassActive]);

  const initializeVectorLayers = () => {
    const initialLayers = [
      {
        id: 'trees',
        name: '樹木',
        type: 'point',
        visible: true,
        color: '#10B981',
        data: trees.map(tree => ({
          id: tree.id,
          coordinates: [tree.lng, tree.lat],
          properties: { ...tree }
        }))
      },
      {
        id: 'work_areas',
        name: '作業エリア',
        type: 'polygon', 
        visible: true,
        color: '#3B82F6',
        data: workAreas.map(area => ({
          id: area.id,
          coordinates: area.boundary ? [area.boundary.map(coord => [coord[1], coord[0]])] : [],
          properties: { ...area }
        }))
      },
      {
        id: 'gps_track',
        name: 'GPS軌跡',
        type: 'line',
        visible: true,
        color: '#EF4444',
        data: trackingPath.length > 1 ? [{
          id: 'current_track',
          coordinates: trackingPath.map(point => [point.lng, point.lat]),
          properties: { name: '現在の軌跡', length: trackingPath.length }
        }] : []
      }
    ];
    
    setVectorLayers(initialLayers);
    
    const visibility = {};
    initialLayers.forEach(layer => {
      visibility[layer.id] = layer.visible;
    });
    setLayerVisibility(visibility);
  };

  useEffect(() => {
    initializeVectorLayers();
  }, [trees, workAreas, trackingPath]);

  const startDrawing = (mode) => {
    setDrawingMode(mode);
    setIsDrawing(true);
    setCurrentDrawing([]);
  };

  const finishDrawing = () => {
    if (currentDrawing.length > 0) {
      const newFeature = {
        id: Date.now(),
        coordinates: drawingMode === 'polygon' ? [currentDrawing] : currentDrawing,
        properties: {
          name: `${drawingMode === 'point' ? 'ポイント' : drawingMode === 'line' ? 'ライン' : 'ポリゴン'} ${Date.now()}`,
          createdAt: new Date().toISOString(),
          type: drawingMode
        }
      };

      const layerId = `user_${drawingMode}s`;
      const existingLayer = vectorLayers.find(layer => layer.id === layerId);
      
      if (existingLayer) {
        const updatedLayers = vectorLayers.map(layer =>
          layer.id === layerId
            ? { ...layer, data: [...layer.data, newFeature] }
            : layer
        );
        setVectorLayers(updatedLayers);
      } else {
        const newLayer = {
          id: layerId,
          name: `ユーザー${drawingMode === 'point' ? 'ポイント' : drawingMode === 'line' ? 'ライン' : 'ポリゴン'}`,
          type: drawingMode,
          visible: true,
          color: drawingMode === 'point' ? '#F59E0B' : drawingMode === 'line' ? '#8B5CF6' : '#EC4899',
          data: [newFeature]
        };
        setVectorLayers([...vectorLayers, newLayer]);
        setLayerVisibility({...layerVisibility, [layerId]: true});
      }
    }
    
    setDrawingMode(null);
    setIsDrawing(false);
    setCurrentDrawing([]);
  };

  const handleMapClick = (event) => {
    if (!isDrawing) return;

    const rect = event.currentTarget.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    
    const lng = ((x / rect.width) - 0.5) * 0.01 + (currentPosition?.lng || 139.6500);
    const lat = (0.5 - (y / rect.height)) * 0.01 + (currentPosition?.lat || 35.6760);
    
    const newPoint = [lng, lat];
    
    if (drawingMode === 'point') {
      setCurrentDrawing([newPoint]);
      finishDrawing();
    } else {
      setCurrentDrawing([...currentDrawing, newPoint]);
    }
  };

  const toggleLayerVisibility = (layerId) => {
    setLayerVisibility({
      ...layerVisibility,
      [layerId]: !layerVisibility[layerId]
    });
  };

  const deleteLayer = (layerId) => {
    setVectorLayers(vectorLayers.filter(layer => layer.id !== layerId));
    const newVisibility = { ...layerVisibility };
    delete newVisibility[layerId];
    setLayerVisibility(newVisibility);
  };

  const getMapStyle = () => {
    switch (mapLayerType) {
      case 'satellite':
        return 'bg-gradient-to-br from-green-200 via-yellow-100 to-brown-200';
      case 'terrain':
        return 'bg-gradient-to-br from-green-300 via-yellow-200 to-orange-200';
      default:
        return 'bg-gradient-to-br from-green-100 to-blue-100';
    }
  };

  const downloadOfflineMap = async () => {
    try {
      const mapData = {
        tiles: [],
        bounds: {
          north: 35.6780,
          south: 35.6740,
          east: 139.6540,
          west: 139.6480
        },
        downloadedAt: new Date().toISOString()
      };
      
      setOfflineMapData(mapData);
      alert('オフライン地図データをダウンロードしました');
    } catch (error) {
      alert('地図データのダウンロードに失敗しました');
    }
  };

  const startMeasurement = () => {
    if (currentPosition) {
      const newMeasurement = {
        id: Date.now(),
        startPoint: { ...currentPosition },
        endPoint: null,
        distance: 0,
        timestamp: new Date().toISOString()
      };
      setMeasurements([...measurements, newMeasurement]);
    }
  };

  const calculateDistance = (lat1, lng1, lat2, lng2) => {
    const R = 6371e3;
    const φ1 = lat1 * Math.PI/180;
    const φ2 = lat2 * Math.PI/180;
    const Δφ = (lat2-lat1) * Math.PI/180;
    const Δλ = (lng2-lng1) * Math.PI/180;

    const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ/2) * Math.sin(Δλ/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return R * c;
  };

  const exportData = (format) => {
    const data = {
      trees: trees,
      workAreas: workAreas,
      trackingPath: trackingPath,
      measurements: measurements,
      vectorLayers: vectorLayers,
      exportedAt: new Date().toISOString()
    };

    let content, filename, mimeType;

    switch (format) {
      case 'json':
        content = JSON.stringify(data, null, 2);
        filename = `forest_data_${new Date().toISOString().split('T')[0]}.json`;
        mimeType = 'application/json';
        break;
      case 'csv':
        const csvContent = trees.map(tree => 
          `${tree.id},${tree.species},${tree.health},${tree.lat},${tree.lng},${tree.diameter},${tree.height},${tree.lastCheck}`
        ).join('\n');
        content = 'ID,樹種,健康状態,緯度,経度,直径,高さ,最終確認\n' + csvContent;
        filename = `forest_trees_${new Date().toISOString().split('T')[0]}.csv`;
        mimeType = 'text/csv';
        break;
      default:
        return;
    }

    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    const exportRecord = {
      id: Date.now(),
      format: format,
      filename: filename,
      timestamp: new Date().toISOString(),
      recordCount: trees.length
    };
    setDataExports([...dataExports, exportRecord]);
  };

  const startTracking = () => {
    if (navigator.geolocation) {
      setIsTracking(true);
      setTrackingPath([]);
      
      watchIdRef.current = navigator.geolocation.watchPosition(
        (position) => {
          const newPos = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
            timestamp: Date.now()
          };
          setCurrentPosition(newPos);
          setTrackingPath(prev => [...prev, newPos]);
        },
        (error) => console.error('GPS追跡エラー:', error),
        { enableHighAccuracy: true, maximumAge: 10000, timeout: 5000 }
      );
    }
  };

  const stopTracking = () => {
    if (watchIdRef.current) {
      navigator.geolocation.clearWatch(watchIdRef.current);
      watchIdRef.current = null;
    }
    setIsTracking(false);
  };

  const addNewTree = () => {
    if (currentPosition) {
      const newTree = {
        id: trees.length + 1,
        species: '新規登録木',
        health: 'healthy',
        lat: currentPosition.lat + (Math.random() - 0.5) * 0.001,
        lng: currentPosition.lng + (Math.random() - 0.5) * 0.001,
        diameter: 0,
        height: 0,
        lastCheck: new Date().toISOString().split('T')[0],
        photos: [],
        notes: ''
      };
      setTrees([...trees, newTree]);
      setSelectedTree(newTree);
    }
  };

  const getHealthColor = (health) => {
    switch (health) {
      case 'healthy': return 'text-green-600 bg-green-100';
      case 'warning': return 'text-yellow-600 bg-yellow-100';
      case 'critical': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'text-blue-600 bg-blue-100';
      case 'maintenance': return 'text-orange-600 bg-orange-100';
      case 'completed': return 'text-green-600 bg-green-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const MapView = () => (
    <div className={`relative h-full ${getMapStyle()} rounded-lg overflow-hidden`}>
      {/* Map Header */}
      <div className="absolute top-2 left-2 right-2 z-20 flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-2 sm:space-y-0">
        <div className="bg-white rounded-lg shadow-lg px-2 sm:px-4 py-2 flex flex-wrap items-center text-xs sm:text-sm">
          <div className="flex items-center space-x-1 sm:space-x-2">
            {isOffline ? <WifiOff className="w-3 h-3 sm:w-4 sm:h-4 text-red-500" /> : <Wifi className="w-3 h-3 sm:w-4 sm:h-4 text-green-500" />}
            <Navigation className="w-4 h-4 sm:w-5 sm:h-5 text-blue-600" />
          </div>
          <span className="font-medium ml-1 sm:ml-2 truncate">
            {currentPosition ? `${currentPosition.lat.toFixed(4)}, ${currentPosition.lng.toFixed(4)}` : '位置取得中...'}
          </span>
          {isCompassActive && (
            <div className="flex items-center space-x-1 ml-2 px-2 py-1 bg-blue-100 rounded">
              <Compass className="w-3 h-3 sm:w-4 sm:h-4 text-blue-600" />
              <span className="text-xs sm:text-sm font-medium text-blue-600">{compass}°</span>
            </div>
          )}
        </div>
        <div className="flex flex-wrap gap-1 sm:gap-2">
          <button
            onClick={() => setIsCompassActive(!isCompassActive)}
            className={`p-1.5 sm:p-2 rounded-lg shadow-lg ${isCompassActive ? 'bg-blue-500 text-white' : 'bg-white text-gray-600'} hover:bg-blue-600 hover:text-white transition-colors`}
            title="コンパス"
          >
            <Compass className="w-4 h-4 sm:w-5 sm:h-5" />
          </button>
          <button
            onClick={startMeasurement}
            className="p-1.5 sm:p-2 bg-white text-gray-600 rounded-lg shadow-lg hover:bg-gray-50 transition-colors"
            title="距離測定"
          >
            <Ruler className="w-4 h-4 sm:w-5 sm:h-5" />
          </button>
          <button
            onClick={downloadOfflineMap}
            className="p-1.5 sm:p-2 bg-white text-gray-600 rounded-lg shadow-lg hover:bg-gray-50 transition-colors"
            title="オフライン地図ダウンロード"
          >
            <Download className="w-4 h-4 sm:w-5 sm:h-5" />
          </button>
          <button
            onClick={isTracking ? stopTracking : startTracking}
            className={`px-2 sm:px-4 py-1.5 sm:py-2 rounded-lg shadow-lg text-xs sm:text-sm font-medium ${
              isTracking 
                ? 'bg-red-500 text-white hover:bg-red-600' 
                : 'bg-green-500 text-white hover:bg-green-600'
            } transition-colors`}
          >
            {isTracking ? 'GPS停止' : 'GPS開始'}
          </button>
          <button
            onClick={addNewTree}
            className="bg-blue-500 text-white p-1.5 sm:px-4 sm:py-2 rounded-lg shadow-lg hover:bg-blue-600 transition-colors"
          >
            <Plus className="w-4 h-4 sm:w-5 sm:h-5" />
          </button>
        </div>
      </div>

      {/* Map Layer Controls */}
      <div className="absolute top-20 left-2 z-20">
        <div className="bg-white rounded-lg shadow-lg p-2">
          <div className="flex flex-col space-y-1">
            <button
              onClick={() => setMapLayerType('standard')}
              className={`px-3 py-1 text-xs rounded ${mapLayerType === 'standard' ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700'} transition-colors`}
            >
              標準地図
            </button>
            <button
              onClick={() => setMapLayerType('satellite')}
              className={`px-3 py-1 text-xs rounded ${mapLayerType === 'satellite' ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700'} transition-colors`}
            >
              衛星画像
            </button>
            <button
              onClick={() => setMapLayerType('terrain')}
              className={`px-3 py-1 text-xs rounded ${mapLayerType === 'terrain' ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-700'} transition-colors`}
            >
              地形図
            </button>
          </div>
        </div>
      </div>

      {/* Drawing Tools */}
      <div className="absolute top-20 right-2 z-20">
        <div className="bg-white rounded-lg shadow-lg p-2">
          <div className="flex flex-col space-y-1">
            <button
              onClick={() => startDrawing('point')}
              className={`p-2 rounded ${drawingMode === 'point' ? 'bg-orange-500 text-white' : 'bg-gray-100 text-gray-700'} hover:bg-orange-600 hover:text-white transition-colors`}
              title="ポイント描画"
            >
              <Circle className="w-4 h-4" />
            </button>
            <button
              onClick={() => startDrawing('line')}
              className={`p-2 rounded ${drawingMode === 'line' ? 'bg-purple-500 text-white' : 'bg-gray-100 text-gray-700'} hover:bg-purple-600 hover:text-white transition-colors`}
              title="ライン描画"
            >
              <Minus className="w-4 h-4" />
            </button>
            <button
              onClick={() => startDrawing('polygon')}
              className={`p-2 rounded ${drawingMode === 'polygon' ? 'bg-pink-500 text-white' : 'bg-gray-100 text-gray-700'} hover:bg-pink-600 hover:text-white transition-colors`}
              title="ポリゴン描画"
            >
              <Square className="w-4 h-4" />
            </button>
            {isDrawing && (
              <button
                onClick={finishDrawing}
                className="p-2 rounded bg-green-500 text-white hover:bg-green-600 transition-colors"
                title="描画完了"
              >
                <CheckCircle className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Layer Panel */}
      <div className="absolute bottom-20 left-2 max-w-xs z-20">
        <div className="bg-white rounded-lg shadow-lg p-3 max-h-48 overflow-y-auto">
          <div className="flex items-center justify-between mb-2">
            <h4 className="text-sm font-semibold text-gray-800">レイヤー</h4>
            <Layers className="w-4 h-4 text-gray-600" />
          </div>
          <div className="space-y-2">
            {vectorLayers.map(layer => (
              <div key={layer.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                <div className="flex items-center space-x-2">
                  <div 
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: layer.color }}
                  />
                  <button
                    onClick={() => toggleLayerVisibility(layer.id)}
                    className="flex items-center space-x-1"
                  >
                    {layerVisibility[layer.id] ? (
                      <Eye className="w-3 h-3 text-gray-600" />
                    ) : (
                      <EyeOff className="w-3 h-3 text-gray-400" />
                    )}
                    <span className={`text-xs ${layerVisibility[layer.id] ? 'text-gray-800' : 'text-gray-400'}`}>
                      {layer.name}
                    </span>
                  </button>
                </div>
                <div className="flex items-center space-x-1">
                  <span className="text-xs text-gray-500">{layer.data.length}</span>
                  {layer.id.startsWith('user_') && (
                    <button
                      onClick={() => deleteLayer(layer.id)}
                      className="text-red-500 hover:text-red-700"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Drawing Status */}
      {isDrawing && (
        <div className="absolute top-32 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-20">
          <div className="text-sm font-medium">
            {drawingMode === 'point' ? 'ポイントをクリック' : 
             drawingMode === 'line' ? `ライン描画中 (${currentDrawing.length}点)` :
             `ポリゴン描画中 (${currentDrawing.length}点)`}
          </div>
          {(drawingMode === 'line' || drawingMode === 'polygon') && currentDrawing.length > 0 && (
            <div className="text-xs opacity-90">
              {drawingMode === 'line' ? '続けてクリックしてライン描画' : '3点以上でポリゴン完成'}
            </div>
          )}
        </div>
      )}

      {/* Map Content */}
      <div className="h-full pt-16 sm:pt-20 p-2 sm:p-4">
        <div 
          className="relative h-full bg-green-50 rounded-lg border-2 border-dashed border-green-300 overflow-hidden cursor-crosshair"
          onClick={handleMapClick}
        >
          {/* Current Position */}
          {currentPosition && (
            <div 
              className="absolute w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-lg animate-pulse z-10"
              style={{ 
                left: '50%', 
                top: '50%', 
                transform: 'translate(-50%, -50%)'
              }}
              title="現在位置"
            />
          )}

          {/* Render Vector Layers */}
          {vectorLayers.map(layer => {
            if (!layerVisibility[layer.id]) return null;
            
            return layer.data.map((feature, featureIndex) => {
              if (layer.type === 'point') {
                return (
                  <div
                    key={`${layer.id}-${featureIndex}`}
                    className="absolute w-3 h-3 rounded-full border-2 border-white shadow-lg cursor-pointer transform hover:scale-125 transition-transform"
                    style={{
                      backgroundColor: layer.color,
                      left: `${((feature.coordinates[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50)}%`,
                      top: `${(50 - (feature.coordinates[1] - (currentPosition?.lat || 35.6760)) * 1000)}%`
                    }}
                    title={feature.properties.name || `${layer.name} ${featureIndex + 1}`}
                  />
                );
              } else if (layer.type === 'line' && feature.coordinates.length > 1) {
                return (
                  <svg key={`${layer.id}-${featureIndex}`} className="absolute inset-0 w-full h-full pointer-events-none">
                    <polyline
                      points={feature.coordinates.map(coord => {
                        const x = ((coord[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50) * 5;
                        const y = (50 - (coord[1] - (currentPosition?.lat || 35.6760)) * 1000) * 5;
                        return `${x},${y}`;
                      }).join(' ')}
                      stroke={layer.color}
                      strokeWidth="3"
                      fill="none"
                      strokeDasharray={layer.id === 'gps_track' ? '5,5' : 'none'}
                      className={layer.id === 'gps_track' ? 'animate-pulse' : ''}
                    />
                  </svg>
                );
              } else if (layer.type === 'polygon' && feature.coordinates.length > 0) {
                return (
                  <svg key={`${layer.id}-${featureIndex}`} className="absolute inset-0 w-full h-full pointer-events-none">
                    <polygon
                      points={feature.coordinates[0].map(coord => {
                        const x = ((coord[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50) * 5;
                        const y = (50 - (coord[1] - (currentPosition?.lat || 35.6760)) * 1000) * 5;
                        return `${x},${y}`;
                      }).join(' ')}
                      stroke={layer.color}
                      strokeWidth="2"
                      fill={layer.color}
                      fillOpacity="0.2"
                    />
                  </svg>
                );
              }
              return null;
            });
          })}

          {/* Current Drawing */}
          {isDrawing && currentDrawing.length > 0 && (
            <svg className="absolute inset-0 w-full h-full pointer-events-none">
              {drawingMode === 'line' && currentDrawing.length > 1 && (
                <polyline
                  points={currentDrawing.map(coord => {
                    const x = ((coord[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50) * 5;
                    const y = (50 - (coord[1] - (currentPosition?.lat || 35.6760)) * 1000) * 5;
                    return `${x},${y}`;
                  }).join(' ')}
                  stroke="#059669"
                  strokeWidth="3"
                  fill="none"
                  strokeDasharray="5,5"
                />
              )}
              {drawingMode === 'polygon' && currentDrawing.length > 2 && (
                <polygon
                  points={currentDrawing.map(coord => {
                    const x = ((coord[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50) * 5;
                    const y = (50 - (coord[1] - (currentPosition?.lat || 35.6760)) * 1000) * 5;
                    return `${x},${y}`;
                  }).join(' ')}
                  stroke="#059669"
                  strokeWidth="2"
                  fill="#059669"
                  fillOpacity="0.3"
                  strokeDasharray="5,5"
                />
              )}
              {/* Draw current drawing points */}
              {currentDrawing.map((coord, index) => (
                <circle
                  key={index}
                  cx={((coord[0] - (currentPosition?.lng || 139.6500)) * 1000 + 50) * 5}
                  cy={(50 - (coord[1] - (currentPosition?.lat || 35.6760)) * 1000) * 5}
                  r="4"
                  fill="#059669"
                  stroke="white"
                  strokeWidth="2"
                />
              ))}
            </svg>
          )}

          {/* Measurements */}
          {measurements.map((measurement, index) => (
            <div key={measurement.id}>
              <div 
                className="absolute w-3 h-3 bg-yellow-500 rounded-full border-2 border-white shadow-lg"
                style={{ left: `${30 + index * 10}%`, top: `${40 + index * 5}%` }}
                title={`測定開始点 ${index + 1}`}
              />
              {measurement.endPoint && (
                <>
                  <svg className="absolute inset-0 w-full h-full pointer-events-none">
                    <line
                      x1={`${30 + index * 10}%`}
                      y1={`${40 + index * 5}%`}
                      x2={`${35 + index * 10}%`}
                      y2={`${45 + index * 5}%`}
                      stroke="#EAB308"
                      strokeWidth="2"
                      strokeDasharray="5,5"
                    />
                  </svg>
                  <div 
                    className="absolute w-3 h-3 bg-red-500 rounded-full border-2 border-white shadow-lg"
                    style={{ left: `${35 + index * 10}%`, top: `${45 + index * 5}%` }}
                    title={`測定終了点 ${index + 1}: ${measurement.distance.toFixed(1)}m`}
                  />
                </>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Tree Details Panel */}
      {selectedTree && (
        <div className="absolute bottom-2 left-2 right-2 sm:bottom-4 sm:left-4 sm:right-4 bg-white rounded-lg shadow-xl p-3 sm:p-4 max-h-48 overflow-y-auto z-20">
          <div className="flex justify-between items-start mb-3">
            <h3 className="text-lg font-bold text-gray-800">{selectedTree.species}</h3>
            <button
              onClick={() => setSelectedTree(null)}
              className="text-gray-400 hover:text-gray-600"
            >
              ✕
            </button>
          </div>
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span className="text-gray-600">健康状態:</span>
              <span className={`ml-2 px-2 py-1 rounded text-xs font-medium ${getHealthColor(selectedTree.health)}`}>
                {selectedTree.health}
              </span>
            </div>
            <div>
              <span className="text-gray-600">直径:</span>
              <span className="ml-2 font-medium">{selectedTree.diameter}cm</span>
            </div>
            <div>
              <span className="text-gray-600">高さ:</span>
              <span className="ml-2 font-medium">{selectedTree.height}m</span>
            </div>
            <div>
              <span className="text-gray-600">最終確認:</span>
              <span className="ml-2 font-medium">{selectedTree.lastCheck}</span>
            </div>
          </div>
          {selectedTree.notes && (
            <div className="mt-3">
              <span className="text-gray-600 text-sm">メモ:</span>
              <p className="text-sm text-gray-800 mt-1">{selectedTree.notes}</p>
            </div>
          )}
          <div className="flex justify-end space-x-2 mt-4">
            <button className="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 transition-colors">
              編集
            </button>
            <button className="bg-green-500 text-white px-3 py-1 rounded text-sm hover:bg-green-600 transition-colors flex items-center">
              <Camera className="w-4 h-4 mr-1" />
              写真
            </button>
            <button 
              className="bg-purple-500 text-white px-3 py-1 rounded text-sm hover:bg-purple-600 transition-colors"
              onClick={() => {
                if (currentPosition) {
                  const distance = calculateDistance(
                    currentPosition.lat, currentPosition.lng,
                    selectedTree.lat, selectedTree.lng
                  );
                  alert(`現在位置からの距離: ${distance.toFixed(1)}m`);
                }
              }}
            >
              距離測定
            </button>
          </div>
        </div>
      )}
    </div>
  );

  const TreeListView = () => (
    <div className="h-full overflow-y-auto">
      <div className="p-4 border-b bg-white">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-800">樹木一覧</h2>
          <button
            onClick={addNewTree}
            className="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition-colors flex items-center"
          >
            <Plus className="w-4 h-4 mr-2" />
            新規登録
          </button>
        </div>
        <div className="flex space-x-2">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="樹木を検索..."
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <button className="flex items-center px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            <Filter className="w-4 h-4 mr-2" />
            フィルター
          </button>
        </div>
      </div>

      <div className="divide-y divide-gray-200">
        {trees.map(tree => (
          <div
            key={tree.id}
            className="p-4 hover:bg-gray-50 cursor-pointer transition-colors"
            onClick={() => setSelectedTree(tree)}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${getHealthColor(tree.health)}`}>
                  <Trees className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-800">{tree.species}</h3>
                  <p className="text-sm text-gray-600">直径: {tree.diameter}cm | 高さ: {tree.height}m</p>
                </div>
              </div>
              <div className="text-right">
                <div className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${getHealthColor(tree.health)}`}>
                  {tree.health === 'healthy' && <CheckCircle className="w-3 h-3 mr-1" />}
                  {tree.health === 'warning' && <AlertTriangle className="w-3 h-3 mr-1" />}
                  {tree.health === 'critical' && <AlertTriangle className="w-3 h-3 mr-1" />}
                  {tree.health}
                </div>
                <p className="text-xs text-gray-500 mt-1">最終確認: {tree.lastCheck}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const AnalyticsView = () => (
    <div className="h-full overflow-y-auto p-4 space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">総樹木数</p>
              <p className="text-2xl font-bold text-gray-900">{trees.length}</p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <Trees className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">健康な樹木</p>
              <p className="text-2xl font-bold text-green-600">
                {trees.filter(t => t.health === 'healthy').length}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <CheckCircle className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">要注意樹木</p>
              <p className="text-2xl font-bold text-yellow-600">
                {trees.filter(t => t.health === 'warning').length}
              </p>
            </div>
            <div className="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
              <AlertTriangle className="w-6 h-6 text-yellow-600" />
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">作業エリア状況</h3>
        <div className="space-y-3">
          {workAreas.map(area => (
            <div key={area.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div>
                <h4 className="font-medium text-gray-800">{area.name}</h4>
                <p className="text-sm text-gray-600">{area.trees}本の樹木</p>
              </div>
              <div className="text-right">
                <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${getStatusColor(area.status)}`}>
                  {area.status}
                </span>
                <p className="text-xs text-gray-500 mt-1">最終訪問: {area.lastVisit}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* GIS統計 */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">GIS統計</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-600">ベクターレイヤー数</p>
            <p className="text-xl font-bold text-blue-600">{vectorLayers.length}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">地図タイプ</p>
            <p className="text-xl font-bold text-purple-600">
              {mapLayerType === 'standard' ? '標準地図' : 
               mapLayerType === 'satellite' ? '衛星画像' : '地形図'}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600">測定記録</p>
            <p className="text-xl font-bold text-orange-600">{measurements.length}件</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">GPS追跡点</p>
            <p className="text-xl font-bold text-red-600">{trackingPath.length}点</p>
          </div>
        </div>
      </div>

      {/* システム状態 */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h3 className="text-lg font-semibold text-gray-800 mb-4">システム状態</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-600">接続状態</p>
            <div className="flex items-center space-x-2">
              {isOffline ? <WifiOff className="w-4 h-4 text-red-500" /> : <Wifi className="w-4 h-4 text-green-500" />}
              <p className={`text-lg font-bold ${isOffline ? 'text-red-600' : 'text-green-600'}`}>
                {isOffline ? 'オフライン' : 'オンライン'}
              </p>
            </div>
          </div>
          <div>
            <p className="text-sm text-gray-600">オフライン地図</p>
            <p className={`text-lg font-bold ${offlineMapData ? 'text-green-600' : 'text-gray-600'}`}>
              {offlineMapData ? '利用可能' : '未ダウンロード'}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600">データエクスポート</p>
            <p className="text-lg font-bold text-indigo-600">{dataExports.length}回</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">追跡状態</p>
            <p className={`text-lg font-bold ${isTracking ? 'text-green-600' : 'text-gray-600'}`}>
              {isTracking ? 'アクティブ' : '停止中'}
            </p>
          </div>
        </div>
      </div>
    </div>
  );

  // データ管理ビュー
  const DataManagementView = () => (
    <div className="h-full overflow-y-auto p-4 space-y-6">
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-800">データ管理</h2>
          <div className="flex space-x-2">
            <button
              onClick={() => exportData('json')}
              className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors flex items-center"
            >
              <Database className="w-4 h-4 mr-2" />
              JSON出力
            </button>
            <button
              onClick={() => exportData('csv')}
              className="bg-green-500 text-white px-4 py-2 rounded-lg hover:bg-green-600 transition-colors flex items-center"
            >
              <FileText className="w-4 h-4 mr-2" />
              CSV出力
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-2">樹木データ</h3>
            <p className="text-2xl font-bold text-green-600">{trees.length}件</p>
            <p className="text-sm text-gray-600">登録樹木数</p>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-2">GPS追跡</h3>
            <p className="text-2xl font-bold text-blue-600">{trackingPath.length}点</p>
            <p className="text-sm text-gray-600">記録ポイント</p>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-2">測定記録</h3>
            <p className="text-2xl font-bold text-purple-600">{measurements.length}件</p>
            <p className="text-sm text-gray-600">距離測定</p>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-semibold text-gray-800 mb-2">ベクターレイヤー</h3>
            <p className="text-2xl font-bold text-orange-600">{vectorLayers.length}層</p>
            <p className="text-sm text-gray-600">GISレイヤー</p>
          </div>
        </div>

        {/* エクスポート履歴 */}
        <div>
          <h3 className="text-lg font-semibold text-gray-800 mb-3">エクスポート履歴</h3>
          <div className="space-y-2">
            {dataExports.length === 0 ? (
              <p className="text-gray-500 text-center py-4">エクスポート履歴がありません</p>
            ) : (
              dataExports.map(exportRecord => (
                <div key={exportRecord.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div>
                    <h4 className="font-medium text-gray-800">{exportRecord.filename}</h4>
                    <p className="text-sm text-gray-600">
                      {exportRecord.format.toUpperCase()} • {exportRecord.recordCount}件のデータ
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-500">
                      {new Date(exportRecord.timestamp).toLocaleString('ja-JP')}
                    </p>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* オフライン地図管理 */}
      <div className="bg-white rounded-lg shadow-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-800">オフライン地図</h3>
          <button
            onClick={downloadOfflineMap}
            className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 transition-colors flex items-center"
          >
            <Download className="w-4 h-4 mr-2" />
            地図ダウンロード
          </button>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-600">地図データ状態</p>
            <p className={`text-lg font-bold ${offlineMapData ? 'text-green-600' : 'text-gray-600'}`}>
              {offlineMapData ? '利用可能' : '未ダウンロード'}
            </p>
          </div>
          <div>
            <p className="text-sm text-gray-600">ダウンロード日時</p>
            <p className="text-lg font-bold text-blue-600">
              {offlineMapData ? new Date(offlineMapData.downloadedAt).toLocaleDateString('ja-JP') : '-'}
            </p>
          </div>
        </div>
      </div>
    </div>
  );

  const tabs = [
    { id: 'map', name: 'マップ', icon: MapPin, component: MapView },
    { id: 'trees', name: '樹木', icon: Trees, component: TreeListView },
    { id: 'analytics', name: '分析', icon: BarChart3, component: AnalyticsView },
    { id: 'data', name: 'データ', icon: Database, component: DataManagementView }
  ];

  const ActiveComponent = tabs.find(tab => tab.id === activeTab)?.component || MapView;

  return (
    <div className="h-screen bg-gray-100 flex flex-col">
      {/* Header */}
      <header className="bg-green-600 text-white shadow-lg">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-8 h-8 bg-green-500 rounded-lg flex items-center justify-center">
                <Trees className="w-5 h-5" />
              </div>
              <div>
                <h1 className="text-xl font-bold">森林管理GIS</h1>
                <p className="text-sm text-green-100">GPS追跡 & ベクターレイヤーシステム</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              {isTracking && (
                <div className="flex items-center space-x-2 bg-green-500 px-3 py-1 rounded-full">
                  <div className="w-2 h-2 bg-white rounded-full animate-pulse"></div>
                  <span className="text-sm font-medium">GPS追跡中</span>
                </div>
              )}
              {isDrawing && (
                <div className="flex items-center space-x-2 bg-orange-500 px-3 py-1 rounded-full">
                  <div className="w-2 h-2 bg-white rounded-full animate-pulse"></div>
                  <span className="text-sm font-medium">描画中</span>
                </div>
              )}
              <button className="p-2 hover:bg-green-500 rounded-lg transition-colors">
                <Settings className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Sidebar */}
        <nav className="w-12 sm:w-16 bg-white shadow-lg">
          <div className="p-1 sm:p-2 space-y-1 sm:space-y-2">
            {tabs.map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-10 h-10 sm:w-12 sm:h-12 rounded-lg flex items-center justify-center transition-colors ${
                  activeTab === tab.id
                    ? 'bg-green-100 text-green-600'
                    : 'text-gray-400 hover:text-gray-600 hover:bg-gray-100'
                }`}
                title={tab.name}
              >
                <tab.icon className="w-5 h-5 sm:w-6 sm:h-6" />
              </button>
            ))}
          </div>
        </nav>

        {/* Content Area */}
        <main className="flex-1 overflow-hidden">
          <ActiveComponent />
        </main>
      </div>
    </div>
  );
};

export default ForestManagementGIS;
                