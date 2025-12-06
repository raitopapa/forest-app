import React, { useState, useEffect, useRef } from 'react';
import {
  SafeAreaView,
  View,
  Text,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Modal,
  Alert,
  Platform,
  StyleSheet,
  Dimensions,
  Image,
} from 'react-native';
import {
  MapPin,
  TreePine,
  BarChart3,
  Settings,
  Search,
  Plus,
  Edit,
  Trash2,
  Save,
  Camera,
  AlertTriangle,
  Activity,
  Users,
  Calendar,
  FileText,
  Navigation,
  Layers,
  Minus,
  Upload,
} from 'lucide-react-native';
import MapView, { Marker, PROVIDER_DEFAULT, UrlTile, Polyline, Polygon } from 'react-native-maps';
import tw from 'twrnc';
import { launchImageLibrary } from 'react-native-image-picker';
import { api } from './services/api';

const ForestManagementSystem = () => {
  const [activeTab, setActiveTab] = useState('map');
  const [forestAreas, setForestAreas] = useState<any[]>([]);
  const [trees, setTrees] = useState<any[]>([]);

  const [selectedArea, setSelectedArea] = useState<any>(null);
  const [selectedTree, setSelectedTree] = useState<any>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddForm, setShowAddForm] = useState(false);
  const [mapLayer, setMapLayer] = useState('std');
  const [mapRegion, setMapRegion] = useState({
    latitude: 36.2048,
    longitude: 140.1024,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
  });
  const [toast, setToast] = useState({ show: false, message: '', type: '' });

  // Drawing State
  const [drawingMode, setDrawingMode] = useState<string | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [currentDrawing, setCurrentDrawing] = useState<any[]>([]);
  const [vectorLayers, setVectorLayers] = useState<any[]>([]);

  const startDrawing = (mode: string) => {
    setDrawingMode(mode);
    setIsDrawing(true);
    setCurrentDrawing([]);
    showToast(`${mode === 'point' ? 'ポイント' : mode === 'line' ? 'ライン' : 'ポリゴン'}描画を開始しました`);
  };

  const finishDrawing = async () => {
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

      // In a real app, we would save this to the backend here
      // await api.createVectorLayer(...)

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
      }
      showToast('描画を保存しました');
    }

    setDrawingMode(null);
    setIsDrawing(false);
    setCurrentDrawing([]);
  };

  const handleMapPress = (e: any) => {
    if (!isDrawing) {
      setSelectedArea(null);
      setSelectedTree(null);
      return;
    }

    const newPoint = e.nativeEvent.coordinate;

    if (drawingMode === 'point') {
      setCurrentDrawing([newPoint]);
    } else {
      setCurrentDrawing([...currentDrawing, newPoint]);
    }
  };

  const mapRef = useRef(null);

  const showToast = (message: string, type = 'success') => {
    setToast({ show: true, message, type });
    setTimeout(() => {
      setToast({ show: false, message: '', type: '' });
    }, 3000);
  };

  const loadData = async () => {
    try {
      const areas = await api.getForestAreas();
      const formattedAreas = areas.map((area: any) => {
        let details = {};
        try {
          details = JSON.parse(area.description || '{}');
        } catch (e) {
          console.warn('Failed to parse area description', e);
        }
        return {
          id: area.id,
          name: area.name,
          treeCount: area.tree_count || details.treeCount || 0,
          health: area.status === 'active' ? '良好' : (area.status === 'maintenance' ? '注意' : '要対応'),
          ...details,
        };
      });
      setForestAreas(formattedAreas);

      const treesData = await api.getTrees();
      setTrees(treesData);
    } catch (e) {
      console.error('Failed to load data.', e);
      showToast('データの読み込みに失敗しました', 'error');
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handlePhotoUpload = async () => {
    if (!selectedTree) return;

    const result = await launchImageLibrary({
      mediaType: 'photo',
      selectionLimit: 1,
    });

    if (result.assets && result.assets.length > 0) {
      try {
        const photo = result.assets[0];
        await api.uploadTreePhoto(selectedTree.id, photo);
        showToast('写真をアップロードしました');
        // Refresh tree data to show new photo if needed
        loadData();
      } catch (e) {
        console.error(e);
        showToast('写真のアップロードに失敗しました', 'error');
      }
    }
  };

  const mapLayers: any = {
    std: {
      name: '標準地図',
      url: 'https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png',
    },
    pale: {
      name: '淡色地図',
      url: 'https://cyberjapandata.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png',
    },
    photo: {
      name: '航空写真',
      url: 'https://cyberjapandata.gsi.go.jp/xyz/seamlessphoto/{z}/{x}/{y}.jpg',
    },
    relief: {
      name: '色別標高図',
      url: 'https://cyberjapandata.gsi.go.jp/xyz/relief/{z}/{x}/{y}.png',
    },
  };

  const MapComponent = () => (
    <View style={tw`h-96 rounded-lg overflow-hidden shadow-lg bg-gray-200`}>
      <MapView
        ref={mapRef}
        style={StyleSheet.absoluteFill}
        provider={PROVIDER_DEFAULT}
        region={mapRegion}
        onRegionChangeComplete={setMapRegion}
        showsUserLocation
        showsMyLocationButton
        onPress={handleMapPress}
      >
        <UrlTile urlTemplate={mapLayers[mapLayer].url} zIndex={-1} />

        {/* Render Vector Layers */}
        {vectorLayers.map(layer => {
          if (!layer.visible) return null;
          return layer.data.map((feature: any, index: number) => {
            if (layer.type === 'point') {
              return (
                <Marker
                  key={`${layer.id}-${index}`}
                  coordinate={feature.coordinates[0]}
                  pinColor={layer.color}
                  title={feature.properties.name}
                />
              );
            } else if (layer.type === 'line') {
              return (
                <Polyline
                  key={`${layer.id}-${index}`}
                  coordinates={feature.coordinates}
                  strokeColor={layer.color}
                  strokeWidth={3}
                />
              );
            } else if (layer.type === 'polygon') {
              return (
                <Polygon
                  key={`${layer.id}-${index}`}
                  coordinates={feature.coordinates[0]}
                  strokeColor={layer.color}
                  fillColor={layer.color + '40'} // Add transparency
                  strokeWidth={2}
                />
              );
            }
            return null;
          });
        })}

        {/* Current Drawing */}
        {isDrawing && (
          <>
            {currentDrawing.map((point, index) => (
              <Marker key={`drawing-point-${index}`} coordinate={point} pinColor="orange" />
            ))}
            {drawingMode === 'line' && currentDrawing.length > 1 && (
              <Polyline coordinates={currentDrawing} strokeColor="orange" strokeWidth={3} />
            )}
            {drawingMode === 'polygon' && currentDrawing.length > 2 && (
              <Polygon coordinates={currentDrawing} strokeColor="orange" fillColor="rgba(255, 165, 0, 0.3)" strokeWidth={2} />
            )}
          </>
        )}

        {/* Forest Areas */}
        {forestAreas.map((area) => (
          <Marker
            key={`area-${area.id}`}
            coordinate={area.coordinates}
            onPress={() => {
              setSelectedArea(area);
              setSelectedTree(null);
            }}
          >
            <View style={tw`p-3 rounded-full shadow-xl border-2 border-white ${area.health === '良好' ? 'bg-green-500' :
              area.health === '注意' ? 'bg-yellow-500' : 'bg-red-500'
              }`}>
              <TreePine size={20} color="white" />
            </View>
          </Marker>
        ))}

        {/* Trees */}
        {trees.map((tree) => (
          <Marker
            key={`tree-${tree.id}`}
            coordinate={{ latitude: tree.lat, longitude: tree.lng }}
            onPress={() => {
              setSelectedTree(tree);
              setSelectedArea(null);
            }}
          >
            <View style={tw`p-2 rounded-full shadow-lg border border-white bg-blue-500`}>
              <TreePine size={16} color="white" />
            </View>
          </Marker>
        ))}
      </MapView>

      {/* Drawing Tools UI */}
      <View style={tw`absolute top-4 right-4 bg-white p-2 rounded-lg shadow-lg`}>
        <View style={tw`flex-col`}>
          <TouchableOpacity onPress={() => startDrawing('point')} style={tw`p-2 mb-2 ${drawingMode === 'point' ? 'bg-orange-100' : ''}`}>
            <View style={tw`w-4 h-4 rounded-full bg-orange-500`} />
          </TouchableOpacity>
          <TouchableOpacity onPress={() => startDrawing('line')} style={tw`p-2 mb-2 ${drawingMode === 'line' ? 'bg-purple-100' : ''}`}>
            <Minus size={20} style={tw`text-purple-600`} />
          </TouchableOpacity>
          <TouchableOpacity onPress={() => startDrawing('polygon')} style={tw`p-2 mb-2 ${drawingMode === 'polygon' ? 'bg-pink-100' : ''}`}>
            <View style={tw`w-4 h-4 border-2 border-pink-500`} />
          </TouchableOpacity>
          {isDrawing && (
            <TouchableOpacity onPress={finishDrawing} style={tw`p-2 bg-green-500 rounded-full items-center justify-center`}>
              <Text style={tw`text-white font-bold`}>✓</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </View>
  );

  const AreaDetails = ({ area, onEdit, onDelete }: any) => {
    if (!area) return null;

    return (
      <View style={tw`bg-white p-6 rounded-lg shadow-lg`}>
        <View style={tw`flex-row justify-between items-start mb-4`}>
          <Text style={tw`text-xl font-bold text-gray-800`}>{area.name}</Text>
          <View style={tw`flex-row`}>
            <TouchableOpacity onPress={onEdit} style={tw`p-2`}>
              <Edit size={16} style={tw`text-blue-600`} />
            </TouchableOpacity>
            <TouchableOpacity onPress={() => onDelete(area.id)} style={tw`p-2`}>
              <Trash2 size={16} style={tw`text-red-600`} />
            </TouchableOpacity>
          </View>
        </View>
        <View style={tw`grid grid-cols-2 gap-4`}>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>面積</Text>
            <Text style={tw`font-medium`}>{area.area} ha</Text>
          </View>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>樹木数</Text>
            <Text style={tw`font-medium`}>{area.treeCount} 本</Text>
          </View>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>健康状態</Text>
            <Text style={tw`font-medium ${area.health === '良好' ? 'text-green-600' :
              area.health === '注意' ? 'text-yellow-600' : 'text-red-600'
              }`}>{area.health}</Text>
          </View>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>最終点検日</Text>
            <Text style={tw`font-medium`}>{area.lastInspection}</Text>
          </View>
        </View>
      </View>
    );
  };

  const TreeDetails = ({ tree }: any) => {
    if (!tree) return null;

    return (
      <View style={tw`bg-white p-6 rounded-lg shadow-lg`}>
        <View style={tw`flex-row justify-between items-start mb-4`}>
          <Text style={tw`text-xl font-bold text-gray-800`}>{tree.species}</Text>
          <TouchableOpacity onPress={() => setSelectedTree(null)} style={tw`p-2`}>
            <Text style={tw`text-gray-500`}>✕</Text>
          </TouchableOpacity>
        </View>
        <View style={tw`grid grid-cols-2 gap-4 mb-4`}>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>高さ</Text>
            <Text style={tw`font-medium`}>{tree.height} m</Text>
          </View>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>直径</Text>
            <Text style={tw`font-medium`}>{tree.diameter} cm</Text>
          </View>
          <View>
            <Text style={tw`text-gray-500 text-xs`}>健康状態</Text>
            <Text style={tw`font-medium ${tree.health === 'healthy' ? 'text-green-600' : 'text-yellow-600'}`}>
              {tree.health === 'healthy' ? '良好' : '注意'}
            </Text>
          </View>
        </View>
        <TouchableOpacity
          onPress={handlePhotoUpload}
          style={tw`bg-blue-500 p-3 rounded-lg flex-row justify-center items-center`}
        >
          <Camera size={20} color="white" style={tw`mr-2`} />
          <Text style={tw`text-white font-bold`}>写真をアップロード</Text>
        </TouchableOpacity>
      </View>
    );
  };

  const StatsDashboard = () => {
    const totalArea = forestAreas.reduce((sum, area) => sum + (parseInt(area.area) || 0), 0);
    const totalTrees = forestAreas.reduce((sum, area) => sum + (parseInt(area.treeCount) || 0), 0);
    const healthyAreas = forestAreas.filter(area => area.health === '良好').length;
    const warningAreas = forestAreas.filter(area => area.health === '注意').length;
    const criticalAreas = forestAreas.filter(area => area.health === '要対応').length;

    return (
      <ScrollView style={tw`p-4`}>
        <View style={tw`flex-row flex-wrap justify-between`}>
          <View style={tw`bg-white p-4 rounded-lg shadow w-full mb-4`}>
            <Text style={tw`text-sm text-gray-600`}>総面積</Text>
            <Text style={tw`text-2xl font-bold text-green-600`}>{totalArea.toLocaleString()} ha</Text>
          </View>
          <View style={tw`bg-white p-4 rounded-lg shadow w-full mb-4`}>
            <Text style={tw`text-sm text-gray-600`}>総樹木数</Text>
            <Text style={tw`text-2xl font-bold text-green-600`}>{totalTrees.toLocaleString()} 本</Text>
          </View>
        </View>
      </ScrollView>
    );
  };

  const AreasList = () => {
    const filteredAreas = forestAreas.filter(area =>
      area.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (area.species && area.species.some((species: string) => species.toLowerCase().includes(searchQuery.toLowerCase())))
    );

    return (
      <View style={tw`p-4`}>
        <View style={tw`bg-white p-4 rounded-lg shadow mb-4`}>
          <TextInput
            placeholder="森林区域名または樹種で検索..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            style={tw`pl-10 pr-4 py-2 border rounded-lg w-full`}
          />
          <Search style={tw`absolute left-6 top-6 text-gray-400`} size={20} />
        </View>
        <ScrollView>
          {filteredAreas.map((area) => (
            <TouchableOpacity
              key={area.id}
              style={tw`bg-white p-4 rounded-lg shadow mb-4`}
              onPress={() => {
                setSelectedArea(area);
                setActiveTab('map');
              }}
            >
              <Text style={tw`text-lg font-semibold text-gray-800`}>{area.name}</Text>
              <Text style={tw`text-gray-500`}>{area.area} ha / {area.treeCount} 本</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    );
  };

  const [editingArea, setEditingArea] = useState<any>(null);

  const handleSaveArea = async (areaData: any) => {
    try {
      if (editingArea) {
        await api.updateForestArea(editingArea.id, areaData);
        showToast('森林区域が更新されました。');
      } else {
        await api.createForestArea({
          ...areaData,
          coordinates: { latitude: mapRegion.latitude, longitude: mapRegion.longitude }
        });
        showToast('新しい森林区域が追加されました。');
      }
      await loadData(); // Reload data
      setShowAddForm(false);
      setEditingArea(null);
    } catch (e) {
      console.error(e);
      showToast('保存に失敗しました', 'error');
    }
  };

  const handleDeleteArea = (areaId: string) => {
    Alert.alert(
      '森林区域の削除',
      'この森林区域を本当に削除しますか？',
      [
        { text: 'キャンセル', style: 'cancel' },
        {
          text: '削除',
          onPress: async () => {
            try {
              await api.deleteForestArea(areaId);
              await loadData(); // Reload data
              setSelectedArea(null);
              showToast('森林区域が削除されました。');
            } catch (e) {
              console.error(e);
              showToast('削除に失敗しました', 'error');
            }
          },
          style: 'destructive',
        },
      ]
    );
  };

  const AreaForm = ({ area, onSave, onCancel }: any) => {
    const [formData, setFormData] = useState({
      name: area?.name || '',
      area: area?.area?.toString() || '',
      treeCount: area?.treeCount?.toString() || '',
      health: area?.health || '良好',
      lastInspection: area?.lastInspection || new Date().toISOString().split('T')[0],
      species: area?.species?.join(', ') || '',
    });

    const handleChange = (name: string, value: string) => {
      setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = () => {
      onSave({
        ...formData,
        area: parseInt(formData.area, 10),
        treeCount: parseInt(formData.treeCount, 10),
        species: formData.species.split(',').map((s: string) => s.trim()),
      });
    };

    return (
      <Modal visible={true} animationType="slide" transparent={true}>
        <View style={tw`flex-1 justify-center items-center bg-black bg-opacity-50`}>
          <View style={tw`bg-white p-8 rounded-lg shadow-2xl w-11/12`}>
            <Text style={tw`text-2xl font-bold mb-6`}>{area ? '森林区域の編集' : '新規森林区域の追加'}</Text>
            <ScrollView>
              <TextInput placeholder="区域名" value={formData.name} onChangeText={(v) => handleChange('name', v)} style={tw`border p-2 rounded mb-4`} />
              <TextInput placeholder="面積 (ha)" value={formData.area} onChangeText={(v) => handleChange('area', v)} style={tw`border p-2 rounded mb-4`} keyboardType="numeric" />
              <TextInput placeholder="樹木数" value={formData.treeCount} onChangeText={(v) => handleChange('treeCount', v)} style={tw`border p-2 rounded mb-4`} keyboardType="numeric" />
              {/* Add more fields as needed */}
            </ScrollView>
            <View style={tw`flex-row justify-end mt-4`}>
              <TouchableOpacity onPress={onCancel} style={tw`px-4 py-2 rounded-md bg-gray-200 mr-2`}>
                <Text>キャンセル</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={handleSubmit} style={tw`px-4 py-2 rounded-md bg-green-600`}>
                <Text style={tw`text-white`}>保存</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    );
  };

  return (
    <SafeAreaView style={tw`flex-1 bg-gray-100`}>
      <View style={tw`bg-white shadow-lg p-4 flex-row justify-between items-center`}>
        <View style={tw`flex-row items-center`}>
          <TreePine size={32} style={tw`text-green-600`} />
          <Text style={tw`text-2xl font-bold text-gray-900 ml-3`}>森林管理システム</Text>
        </View>
        <TouchableOpacity style={tw`p-2`}>
          <Settings size={20} style={tw`text-gray-600`} />
        </TouchableOpacity>
      </View>

      <View style={tw`bg-white border-b border-gray-200 flex-row justify-around`}>
        {[
          { id: 'map', name: '地図表示', icon: MapPin },
          { id: 'stats', name: '統計', icon: BarChart3 },
          { id: 'areas', name: 'エリア一覧', icon: TreePine },
        ].map(({ id, name, icon: Icon }) => (
          <TouchableOpacity
            key={id}
            onPress={() => setActiveTab(id)}
            style={tw`flex-row items-center px-3 py-4 border-b-2 ${activeTab === id ? 'border-green-500' : 'border-transparent'
              }`}
          >
            <Icon size={20} style={tw`${activeTab === id ? 'text-green-600' : 'text-gray-500'}`} />
            <Text style={tw`ml-2 ${activeTab === id ? 'text-green-600' : 'text-gray-500'}`}>{name}</Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={tw`flex-1`}>
        {activeTab === 'map' && (
          <View style={tw`flex-1`}>
            <MapComponent />
            <View style={tw`absolute bottom-0 left-0 right-0 p-4`}>
              {selectedArea ? (
                <AreaDetails
                  area={selectedArea}
                  onEdit={() => {
                    setEditingArea(selectedArea);
                    setShowAddForm(true);
                  }}
                  onDelete={handleDeleteArea}
                />
              ) : selectedTree ? (
                <TreeDetails tree={selectedTree} />
              ) : (
                <View style={tw`bg-white p-6 rounded-lg shadow-lg items-center`}>
                  <TreePine size={48} style={tw`text-gray-300 mb-4`} />
                  <Text style={tw`text-gray-500 text-center`}>
                    地図上の森林区域または樹木をタップして詳細情報を表示してください
                  </Text>
                </View>
              )}
            </View>
          </View>
        )}
        {activeTab === 'stats' && <StatsDashboard />}
        {activeTab === 'areas' && <AreasList />}
      </View>

      {showAddForm && (
        <AreaForm
          area={editingArea}
          onSave={handleSaveArea}
          onCancel={() => {
            setShowAddForm(false);
            setEditingArea(null);
          }}
        />
      )}

      {toast.show && (
        <View style={tw`absolute bottom-8 right-8 px-6 py-3 rounded-lg shadow-lg ${toast.type === 'success' ? 'bg-green-500' : 'bg-red-500'
          }`}>
          <Text style={tw`text-white`}>{toast.message}</Text>
        </View>
      )}
    </SafeAreaView>
  );
};

export default ForestManagementSystem;