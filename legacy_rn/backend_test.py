#!/usr/bin/env python3
"""
Forest Management GIS Backend API Test Suite
Tests all backend endpoints for the forest management application
"""

import requests
import sys
import json
import uuid
from datetime import datetime
from typing import Dict, Any, Optional

class ForestManagementAPITester:
    def __init__(self, base_url="http://localhost:8001"):
        self.base_url = base_url
        self.tests_run = 0
        self.tests_passed = 0
        self.created_resources = {
            'trees': [],
            'work_areas': [],
            'gps_tracks': [],
            'vector_layers': [],
            'measurements': []
        }

    def run_test(self, name: str, method: str, endpoint: str, expected_status: int, 
                 data: Optional[Dict[str, Any]] = None, params: Optional[Dict[str, str]] = None) -> tuple:
        """Run a single API test"""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        headers = {'Content-Type': 'application/json'}

        self.tests_run += 1
        print(f"\n🔍 Testing {name}...")
        print(f"   URL: {method} {url}")
        
        try:
            if method == 'GET':
                response = requests.get(url, headers=headers, params=params)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=headers)
            elif method == 'PUT':
                response = requests.put(url, json=data, headers=headers)
            elif method == 'DELETE':
                response = requests.delete(url, headers=headers)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")

            success = response.status_code == expected_status
            if success:
                self.tests_passed += 1
                print(f"✅ Passed - Status: {response.status_code}")
                try:
                    response_data = response.json() if response.content else {}
                except:
                    response_data = {}
                return True, response_data
            else:
                print(f"❌ Failed - Expected {expected_status}, got {response.status_code}")
                try:
                    error_detail = response.json()
                    print(f"   Error: {error_detail}")
                except:
                    print(f"   Response: {response.text[:200]}")
                return False, {}

        except Exception as e:
            print(f"❌ Failed - Error: {str(e)}")
            return False, {}

    def test_root_endpoint(self):
        """Test the root endpoint"""
        success, response = self.run_test(
            "Root Endpoint",
            "GET",
            "/",
            200
        )
        if success:
            print(f"   Message: {response.get('message', 'N/A')}")
        return success

    def test_tree_crud_operations(self):
        """Test complete CRUD operations for trees"""
        print("\n" + "="*50)
        print("TESTING TREE CRUD OPERATIONS")
        print("="*50)
        
        # Test creating a tree
        tree_data = {
            "species": "スギ",
            "health": "healthy",
            "lat": 35.6762,
            "lng": 139.6503,
            "diameter": 25.5,
            "height": 15.2,
            "notes": "テスト用樹木データ"
        }
        
        success, tree_response = self.run_test(
            "Create Tree",
            "POST",
            "/api/trees",
            200,
            data=tree_data
        )
        
        if not success:
            return False
            
        tree_id = tree_response.get('id')
        if tree_id:
            self.created_resources['trees'].append(tree_id)
            print(f"   Created tree ID: {tree_id}")
        
        # Test getting all trees
        success, trees_response = self.run_test(
            "Get All Trees",
            "GET",
            "/api/trees",
            200
        )
        
        if success:
            print(f"   Found {len(trees_response)} trees")
        
        # Test getting specific tree
        if tree_id:
            success, single_tree = self.run_test(
                "Get Single Tree",
                "GET",
                f"/api/trees/{tree_id}",
                200
            )
            
            if success:
                print(f"   Tree species: {single_tree.get('species', 'N/A')}")
        
        # Test updating tree
        if tree_id:
            update_data = {
                "health": "warning",
                "diameter": 26.0,
                "notes": "更新されたテストデータ"
            }
            
            success, updated_tree = self.run_test(
                "Update Tree",
                "PUT",
                f"/api/trees/{tree_id}",
                200,
                data=update_data
            )
            
            if success:
                print(f"   Updated health: {updated_tree.get('health', 'N/A')}")
        
        return True

    def test_work_area_operations(self):
        """Test work area CRUD operations"""
        print("\n" + "="*50)
        print("TESTING WORK AREA OPERATIONS")
        print("="*50)
        
        # Create work area
        area_data = {
            "name": "エリアA",
            "status": "active",
            "boundary": [
                [35.6762, 139.6503],
                [35.6772, 139.6513],
                [35.6782, 139.6503],
                [35.6762, 139.6503]
            ],
            "description": "テスト用作業エリア"
        }
        
        success, area_response = self.run_test(
            "Create Work Area",
            "POST",
            "/api/work-areas",
            200,
            data=area_data
        )
        
        if success:
            area_id = area_response.get('id')
            if area_id:
                self.created_resources['work_areas'].append(area_id)
                print(f"   Created area ID: {area_id}")
        
        # Get all work areas
        success, areas_response = self.run_test(
            "Get All Work Areas",
            "GET",
            "/api/work-areas",
            200
        )
        
        if success:
            print(f"   Found {len(areas_response)} work areas")
        
        return success

    def test_gps_tracking_operations(self):
        """Test GPS tracking operations"""
        print("\n" + "="*50)
        print("TESTING GPS TRACKING OPERATIONS")
        print("="*50)
        
        # Create GPS track
        track_data = {
            "name": "テスト軌跡",
            "points": [
                {"lat": 35.6762, "lng": 139.6503, "timestamp": datetime.now().isoformat()},
                {"lat": 35.6772, "lng": 139.6513, "timestamp": datetime.now().isoformat()},
                {"lat": 35.6782, "lng": 139.6523, "timestamp": datetime.now().isoformat()}
            ],
            "track_type": "path"
        }
        
        success, track_response = self.run_test(
            "Create GPS Track",
            "POST",
            "/api/gps-tracks",
            200,
            data=track_data
        )
        
        if success:
            track_id = track_response.get('id')
            if track_id:
                self.created_resources['gps_tracks'].append(track_id)
                print(f"   Created track ID: {track_id}")
                print(f"   Track distance: {track_response.get('distance', 0):.2f}m")
        
        # Get all GPS tracks
        success, tracks_response = self.run_test(
            "Get All GPS Tracks",
            "GET",
            "/api/gps-tracks",
            200
        )
        
        if success:
            print(f"   Found {len(tracks_response)} GPS tracks")
        
        return success

    def test_vector_layer_operations(self):
        """Test vector layer operations"""
        print("\n" + "="*50)
        print("TESTING VECTOR LAYER OPERATIONS")
        print("="*50)
        
        # Create vector layer
        layer_data = {
            "name": "テストレイヤー",
            "layer_type": "polygon",
            "color": "#FF0000",
            "data": [
                {
                    "id": str(uuid.uuid4()),
                    "coordinates": [
                        [139.6503, 35.6762],
                        [139.6513, 35.6772],
                        [139.6503, 35.6782],
                        [139.6503, 35.6762]
                    ],
                    "properties": {
                        "name": "テストポリゴン",
                        "type": "polygon"
                    }
                }
            ],
            "visible": True
        }
        
        success, layer_response = self.run_test(
            "Create Vector Layer",
            "POST",
            "/api/vector-layers",
            200,
            data=layer_data
        )
        
        if success:
            layer_id = layer_response.get('id')
            if layer_id:
                self.created_resources['vector_layers'].append(layer_id)
                print(f"   Created layer ID: {layer_id}")
        
        # Get all vector layers
        success, layers_response = self.run_test(
            "Get All Vector Layers",
            "GET",
            "/api/vector-layers",
            200
        )
        
        if success:
            print(f"   Found {len(layers_response)} vector layers")
        
        return success

    def test_measurement_operations(self):
        """Test measurement operations"""
        print("\n" + "="*50)
        print("TESTING MEASUREMENT OPERATIONS")
        print("="*50)
        
        # Create measurement
        measurement_data = {
            "start_point": {"lat": 35.6762, "lng": 139.6503},
            "end_point": {"lat": 35.6772, "lng": 139.6513},
            "distance": 1500.0,
            "measurement_type": "distance"
        }
        
        success, measurement_response = self.run_test(
            "Create Measurement",
            "POST",
            "/api/measurements",
            200,
            data=measurement_data
        )
        
        if success:
            measurement_id = measurement_response.get('id')
            if measurement_id:
                self.created_resources['measurements'].append(measurement_id)
                print(f"   Created measurement ID: {measurement_id}")
        
        # Get all measurements
        success, measurements_response = self.run_test(
            "Get All Measurements",
            "GET",
            "/api/measurements",
            200
        )
        
        if success:
            print(f"   Found {len(measurements_response)} measurements")
        
        return success

    def test_analytics_endpoints(self):
        """Test analytics endpoints"""
        print("\n" + "="*50)
        print("TESTING ANALYTICS ENDPOINTS")
        print("="*50)
        
        # Test analytics summary
        success, analytics_response = self.run_test(
            "Get Analytics Summary",
            "GET",
            "/api/analytics/summary",
            200
        )
        
        if success:
            print(f"   Total trees: {analytics_response.get('total_trees', 0)}")
            print(f"   Healthy trees: {analytics_response.get('healthy_trees', 0)}")
            print(f"   Warning trees: {analytics_response.get('warning_trees', 0)}")
            print(f"   Total areas: {analytics_response.get('total_areas', 0)}")
        
        # Test species distribution
        success, species_response = self.run_test(
            "Get Species Distribution",
            "GET",
            "/api/analytics/species-distribution",
            200
        )
        
        if success:
            print(f"   Species data points: {len(species_response)}")
        
        return success

    def test_export_endpoints(self):
        """Test data export endpoints"""
        print("\n" + "="*50)
        print("TESTING EXPORT ENDPOINTS")
        print("="*50)
        
        # Test JSON export
        success, _ = self.run_test(
            "Export JSON Data",
            "GET",
            "/api/export/json",
            200
        )
        
        # Test CSV export
        success2, _ = self.run_test(
            "Export CSV Data",
            "GET",
            "/api/export/csv",
            200
        )
        
        return success and success2

    def test_report_generation(self):
        """Test report generation endpoints"""
        print("\n" + "="*50)
        print("TESTING REPORT GENERATION")
        print("="*50)
        
        # Test summary report
        success, _ = self.run_test(
            "Generate Summary Report",
            "GET",
            "/api/reports/generate/summary",
            200
        )
        
        # Test full report
        success2, _ = self.run_test(
            "Generate Full Report",
            "GET",
            "/api/reports/generate/full",
            200
        )
        
        return success and success2

    def cleanup_test_data(self):
        """Clean up created test data"""
        print("\n" + "="*50)
        print("CLEANING UP TEST DATA")
        print("="*50)
        
        # Delete created trees
        for tree_id in self.created_resources['trees']:
            self.run_test(
                f"Delete Tree {tree_id[:8]}",
                "DELETE",
                f"/api/trees/{tree_id}",
                200
            )
        
        # Delete created work areas
        for area_id in self.created_resources['work_areas']:
            self.run_test(
                f"Delete Work Area {area_id[:8]}",
                "DELETE",
                f"/api/work-areas/{area_id}",
                200
            )
        
        # Delete created GPS tracks
        for track_id in self.created_resources['gps_tracks']:
            self.run_test(
                f"Delete GPS Track {track_id[:8]}",
                "DELETE",
                f"/api/gps-tracks/{track_id}",
                200
            )
        
        # Delete created vector layers
        for layer_id in self.created_resources['vector_layers']:
            self.run_test(
                f"Delete Vector Layer {layer_id[:8]}",
                "DELETE",
                f"/api/vector-layers/{layer_id}",
                200
            )

    def run_all_tests(self):
        """Run all API tests"""
        print("🚀 Starting Forest Management GIS API Tests")
        print(f"Backend URL: {self.base_url}")
        print("="*60)
        
        # Test basic connectivity
        if not self.test_root_endpoint():
            print("❌ Cannot connect to backend. Stopping tests.")
            return False
        
        # Run all test suites
        test_results = []
        test_results.append(self.test_tree_crud_operations())
        test_results.append(self.test_work_area_operations())
        test_results.append(self.test_gps_tracking_operations())
        test_results.append(self.test_vector_layer_operations())
        test_results.append(self.test_measurement_operations())
        test_results.append(self.test_analytics_endpoints())
        test_results.append(self.test_export_endpoints())
        test_results.append(self.test_report_generation())
        
        # Clean up test data
        self.cleanup_test_data()
        
        # Print final results
        print("\n" + "="*60)
        print("📊 FINAL TEST RESULTS")
        print("="*60)
        print(f"Tests run: {self.tests_run}")
        print(f"Tests passed: {self.tests_passed}")
        print(f"Tests failed: {self.tests_run - self.tests_passed}")
        print(f"Success rate: {(self.tests_passed/self.tests_run)*100:.1f}%")
        
        if all(test_results):
            print("🎉 All test suites passed!")
            return True
        else:
            print("⚠️  Some test suites failed.")
            return False

def main():
    """Main test execution"""
    # Use the public endpoint from environment
    backend_url = "http://localhost:8001"  # This will be the public URL
    
    tester = ForestManagementAPITester(backend_url)
    success = tester.run_all_tests()
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())