import React, { useState, useEffect, useRef } from 'react';
import { 
  MapPin, Trees, BarChart3, Settings, Plus, Search, Filter, 
  Navigation, AlertTriangle, CheckCircle, Camera, Download, 
  Wifi, WifiOff, Database, FileText, Compass, Ruler, Layers, 
  Square, Circle, Minus, Trash2, Eye, EyeOff, Upload, Save
} from 'lucide-react';
import { MapContainer, TileLayer, Marker, Popup, Polygon, Polyline, useMapEvent } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Import API services
import { 
  treeAPI, workAreaAPI, gpsAPI, vectorLayerAPI, 
  measurementAPI, analyticsAPI, reportAPI, exportAPI, 
  mapAPI, downloadBlob, calculateDistance, calculatePolygonArea 
} from './services/api';

// Fix Leaflet default markers issue
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});

// Custom marker icons
const createTreeIcon = (health) => {
  const colors = {
    healthy: '#10B981',
    warning: '#F59E0B',
    critical: '#EF4444'
  };
  
  return L.divIcon({
    className: 'custom-tree-marker',
    html: `<div class="tree-marker-icon tree-marker-${health}" style="background-color: ${colors[health]}">
             <svg width="12" height="12" viewBox="0 0 24 24" fill="white">
               <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
             </svg>
           </div>`,
    iconSize: [24, 24],
    iconAnchor: [12, 12]
  });
};

const ForestManagementGIS = () => {
  // State management
  const [currentPosition, setCurrentPosition] = useState(null);
  const [isTracking, setIsTracking] = useState(false);
  const [activeTab, setActiveTab] = useState('map');
  const [selectedTree, setSelectedTree] = useState(null);
  const [trackingPath, setTrackingPath] = useState([]);
  const [isOffline, setIsOffline] = useState(!navigator.onLine);
  const [measurements, setMeasurements] = useState([]);
  const [isCompassActive, setIsCompassActive] = useState(false);
  const [compass, setCompass] = useState(0);
  const [loading, setLoading] = useState(false);
  
  // Data states
  const [trees, setTrees] = useState([]);
  const [workAreas, setWorkAreas] = useState([]);
  const [gpsTracking, setGpsTracking] = useState([]);
  const [vectorLayers, setVectorLayers] = useState([]);
  const [analyticsData, setAnalyticsData] = useState(null);
  
  // GIS functionality states
  const [mapLayerType, setMapLayerType] = useState('standard');
  const [drawingMode, setDrawingMode] = useState(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [currentDrawing, setCurrentDrawing] = useState([]);
  const [layerVisibility, setLayerVisibility] = useState({});
  
  // Form states
  const [treeForm, setTreeForm] = useState({
    species: '',
    health: 'healthy',
    diameter: 0,
    height: 0,
    notes: ''
  });
  const [areaForm, setAreaForm] = useState({
    name: '',
    status: 'active',
    description: ''
  });
  
  const watchIdRef = useRef(null);
  const mapRef = useRef(null);

  // Initialize data on component mount
  useEffect(() => {
    initializeApp();
    setupEventListeners();
    return cleanup;
  }, []);

  const initializeApp = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadTrees(),
        loadWorkAreas(),
        loadGPSTracks(),
        loadVectorLayers(),
        loadAnalytics()
      ]);
      
      getCurrentPosition();
    } catch (error) {
      console.error('App initialization error:', error);
    } finally {
      setLoading(false);
    }
  };

  const setupEventListeners = () => {
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
  };

  const cleanup = () => {
    window.removeEventListener('online', () => setIsOffline(false));
    window.removeEventListener('offline', () => setIsOffline(true));
    window.removeEventListener('deviceorientation', () => {});
    
    if (watchIdRef.current) {
      navigator.geolocation.clearWatch(watchIdRef.current);
    }
  };

  // Data loading functions
  const loadTrees = async () => {
    try {
      const response = await treeAPI.getAll();
      setTrees(response.data);
    } catch (error) {
      console.error('Failed to load trees:', error);
    }
  };

  const loadWorkAreas = async () => {
    try {
      const response = await workAreaAPI.getAll();
      setWorkAreas(response.data);
    } catch (error) {
      console.error('Failed to load work areas:', error);
    }
  };

  const loadGPSTracks = async () => {
    try {
      const response = await gpsAPI.getAll();
      setGpsTracking(response.data);
    } catch (error) {
      console.error('Failed to load GPS tracks:', error);
    }
  };

  const loadVectorLayers = async () => {
    try {
      const response = await vectorLayerAPI.getAll();
      setVectorLayers(response.data);
      
      // Initialize layer visibility
      const visibility = {};
      response.data.forEach(layer => {
        visibility[layer.id] = layer.visible;
      });
      setLayerVisibility(visibility);
    } catch (error) {
      console.error('Failed to load vector layers:', error);
    }
  };

  const loadAnalytics = async () => {
    try {
      const response = await analyticsAPI.getSummary();
      setAnalyticsData(response.data);
    } catch (error) {
      console.error('Failed to load analytics:', error);
    }
  };

  const getCurrentPosition = () => {
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
  };

  // GPS tracking functions
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

  const stopTracking = async () => {
    if (watchIdRef.current) {
      navigator.geolocation.clearWatch(watchIdRef.current);
      watchIdRef.current = null;
    }
    setIsTracking(false);
    
    // Save GPS track to database
    if (trackingPath.length > 1) {
      try {
        const trackData = {
          name: `GPS軌跡_${new Date().toLocaleDateString('ja-JP')}`,
          points: trackingPath,
          track_type: 'path'
        };
        await gpsAPI.create(trackData);
        await loadGPSTracks(); // Reload tracks
      } catch (error) {
        console.error('Failed to save GPS track:', error);
      }
    }
  };

  // Tree management functions
  const addNewTree = async () => {
    if (currentPosition) {
      const newTreeData = {
        ...treeForm,
        lat: currentPosition.lat + (Math.random() - 0.5) * 0.001,
        lng: currentPosition.lng + (Math.random() - 0.5) * 0.001,
      };
      
      try {
        await treeAPI.create(newTreeData);
        await loadTrees();
        setTreeForm({
          species: '',
          health: 'healthy',
          diameter: 0,
          height: 0,
          notes: ''
        });
      } catch (error) {
        console.error('Failed to create tree:', error);
        alert('樹木の登録に失敗しました');
      }
    }
  };

  const updateTree = async (treeId, updateData) => {
    try {
      await treeAPI.update(treeId, updateData);
      await loadTrees();
      setSelectedTree(null);
    } catch (error) {
      console.error('Failed to update tree:', error);
      alert('樹木の更新に失敗しました');
    }
  };

  const deleteTree = async (treeId) => {
    if (window.confirm('この樹木を削除しますか？')) {
      try {
        await treeAPI.delete(treeId);
        await loadTrees();
        setSelectedTree(null);
      } catch (error) {
        console.error('Failed to delete tree:', error);
        alert('樹木の削除に失敗しました');
      }
    }
  };

  // Photo upload function
  const uploadTreePhoto = async (treeId, file) => {
    try {
      await treeAPI.uploadPhoto(treeId, file);
      await loadTrees();
      alert('写真をアップロードしました');
    } catch (error) {
      console.error('Failed to upload photo:', error);
      alert('写真のアップロードに失敗しました');
    }
  };

  // Drawing functions
  const startDrawing = (mode) => {
    setDrawingMode(mode);
    setIsDrawing(true);
    setCurrentDrawing([]);
  };

  const finishDrawing = async () => {
    if (currentDrawing.length > 0) {
      const newFeature = {
        name: `${drawingMode === 'point' ? 'ポイント' : drawingMode === 'line' ? 'ライン' : 'ポリゴン'} ${Date.now()}`,
        layer_type: drawingMode,
        color: drawingMode === 'point' ? '#F59E0B' : drawingMode === 'line' ? '#8B5CF6' : '#EC4899',
        data: [{
          id: Date.now(),
          coordinates: drawingMode === 'polygon' ? [currentDrawing] : currentDrawing,
          properties: {
            name: `${drawingMode} ${Date.now()}`,
            created_at: new Date().toISOString(),
            type: drawingMode
          }
        }],
        visible: true
      };

      try {
        await vectorLayerAPI.create(newFeature);
        await loadVectorLayers();
      } catch (error) {
        console.error('Failed to save drawing:', error);
      }
    }
    
    setDrawingMode(null);
    setIsDrawing(false);
    setCurrentDrawing([]);
  };

  // Export functions
  const exportData = async (format) => {
    try {
      const response = await exportAPI.exportData(format);
      const filename = `forest_data_${new Date().toISOString().split('T')[0]}.${format}`;
      downloadBlob(response.data, filename);
    } catch (error) {
      console.error('Export failed:', error);
      alert('データのエクスポートに失敗しました');
    }
  };

  const generateReport = async (reportType) => {
    try {
      const response = await reportAPI.generate(reportType);
      const filename = `report_${reportType}_${new Date().toISOString().split('T')[0]}.pdf`;
      downloadBlob(response.data, filename);
    } catch (error) {
      console.error('Report generation failed:', error);
      alert('レポートの生成に失敗しました');
    }
  };

  // Helper functions
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

  // Map click handler component
  const MapClickHandler = () => {
    useMapEvent('click', (e) => {
      if (!isDrawing) return;

      const { lat, lng } = e.latlng;
      const newPoint = [lng, lat];
      
      if (drawingMode === 'point') {
        setCurrentDrawing([newPoint]);
        finishDrawing();
      } else {
        setCurrentDrawing(prev => [...prev, newPoint]);
      }
    });
    return null;
  };

  // Components
  const MapView = () => {
    const defaultCenter = currentPosition ? [currentPosition.lat, currentPosition.lng] : [35.6762, 139.6503];
    
    return (
      <div className="relative h-full">
        {/* Map Controls */}
        <div className="absolute top-2 left-2 right-2 z-10 flex flex-col sm:flex-row justify-between items-start sm:items-center space-y-2 sm:space-y-0">
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
              title="新規樹木登録"
            >
              <Plus className="w-4 h-4 sm:w-5 sm:h-5" />
            </button>
          </div>
        </div>

        {/* Drawing Tools */}
        <div className="absolute top-20 right-2 z-10">
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

        {/* Map Layer Controls */}
        <div className="absolute top-20 left-2 z-10">
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

        {/* Drawing Status */}
        {isDrawing && (
          <div className="absolute top-32 left-1/2 transform -translate-x-1/2 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-10">
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

        {/* Leaflet Map */}
        <MapContainer
          center={defaultCenter}
          zoom={15}
          ref={mapRef}
          className="h-full w-full"
          zoomControl={true}
        >
          <TileLayer
            url={mapAPI.getTileUrl(mapLayerType, '{z}', '{x}', '{y}')}
            attribution='&copy; <a href="https://maps.gsi.go.jp/development/ichiran.html">国土地理院</a>'
          />
          
          {/* Tree markers */}
          {trees.map(tree => (
            <Marker
              key={tree.id}
              position={[tree.lat, tree.lng]}
              icon={createTreeIcon(tree.health)}
              eventHandlers={{
                click: () => setSelectedTree(tree)
              }}
            >
              <Popup>
                <div className="text-sm">
                  <h3 className="font-bold">{tree.species}</h3>
                  <p>健康状態: {tree.health}</p>
                  <p>直径: {tree.diameter}cm</p>
                  <p>高さ: {tree.height}m</p>
                </div>
              </Popup>
            </Marker>
          ))}

          {/* Work area polygons */}
          {workAreas.map(area => (
            area.boundary && area.boundary.length > 0 && (
              <Polygon
                key={area.id}
                positions={area.boundary}
                color="#3B82F6"
                fillColor="#3B82F6"
                fillOpacity={0.2}
              >
                <Popup>
                  <div className="text-sm">
                    <h3 className="font-bold">{area.name}</h3>
                    <p>状態: {area.status}</p>
                    <p>樹木数: {area.tree_count || 0}本</p>
                  </div>
                </Popup>
              </Polygon>
            )
          ))}

          {/* GPS tracking path */}
          {trackingPath.length > 1 && (
            <Polyline
              positions={trackingPath.map(point => [point.lat, point.lng])}
              color="#EF4444"
              weight={3}
              opacity={0.8}
              dashArray="5, 5"
            />
          )}

          {/* Current position */}
          {currentPosition && (
            <Marker
              position={[currentPosition.lat, currentPosition.lng]}
              icon={L.divIcon({
                className: 'current-position-marker',
                html: '<div class="w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-lg gps-pulse"></div>',
                iconSize: [16, 16],
                iconAnchor: [8, 8]
              })}
            />
          )}

          <MapClickHandler />
        </MapContainer>

        {/* Tree Details Panel */}
        {selectedTree && (
          <div className="absolute bottom-2 left-2 right-2 sm:bottom-4 sm:left-4 sm:right-4 bg-white rounded-lg shadow-xl p-3 sm:p-4 max-h-48 overflow-y-auto z-10">
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
                <span className="ml-2 font-medium">{selectedTree.last_check}</span>
              </div>
            </div>
            {selectedTree.notes && (
              <div className="mt-3">
                <span className="text-gray-600 text-sm">メモ:</span>
                <p className="text-sm text-gray-800 mt-1">{selectedTree.notes}</p>
              </div>
            )}
            <div className="flex justify-end space-x-2 mt-4">
              <button 
                className="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 transition-colors"
                onClick={() => {
                  // Open edit form (implement as needed)
                  console.log('Edit tree:', selectedTree.id);
                }}
              >
                編集
              </button>
              <label className="bg-green-500 text-white px-3 py-1 rounded text-sm hover:bg-green-600 transition-colors cursor-pointer flex items-center">
                <Camera className="w-4 h-4 mr-1" />
                写真
                <input
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={(e) => {
                    if (e.target.files[0]) {
                      uploadTreePhoto(selectedTree.id, e.target.files[0]);
                    }
                  }}
                />
              </label>
              <button 
                className="bg-red-500 text-white px-3 py-1 rounded text-sm hover:bg-red-600 transition-colors"
                onClick={() => deleteTree(selectedTree.id)}
              >
                削除
              </button>
            </div>
          </div>
        )}
      </div>
    );
  };

  // Loading component
  if (loading) {
    return (
      <div className="h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="loading-spinner mx-auto mb-4"></div>
          <p className="text-gray-600">アプリケーションを読み込み中...</p>
        </div>
      </div>
    );
  }

  // Tree List View
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
                <p className="text-xs text-gray-500 mt-1">最終確認: {tree.last_check}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  // Analytics View
  const AnalyticsView = () => (
    <div className="h-full overflow-y-auto p-4 space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-lg shadow-lg p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">総樹木数</p>
              <p className="text-2xl font-bold text-gray-900">{analyticsData?.total_trees || 0}</p>
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
              <p className="text-2xl font-bold text-green-600">{analyticsData?.healthy_trees || 0}</p>
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
              <p className="text-2xl font-bold text-yellow-600">{analyticsData?.warning_trees || 0}</p>
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
                <p className="text-sm text-gray-600">{area.tree_count || 0}本の樹木</p>
              </div>
              <div className="text-right">
                <span className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${getStatusColor(area.status)}`}>
                  {area.status}
                </span>
                <p className="text-xs text-gray-500 mt-1">最終訪問: {area.last_visit}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  // Data Management View
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
            <button
              onClick={() => generateReport('full')}
              className="bg-purple-500 text-white px-4 py-2 rounded-lg hover:bg-purple-600 transition-colors flex items-center"
            >
              <Download className="w-4 h-4 mr-2" />
              PDF報告書
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
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