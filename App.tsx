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
} from 'lucide-react-native';
import MapView, { Marker, PROVIDER_DEFAULT, UrlTile } from 'react-native-maps';
import tw from 'twrnc';
import AsyncStorage from '@react-native-async-storage/async-storage';

const ForestManagementSystem = () => {
  const [activeTab, setActiveTab] = useState('map');
  const [forestAreas, setForestAreas] = useState([
    {
      id: 1,
      name: '北部森林区域A',
      area: 1250,
      treeCount: 3200,
      health: '良好',
      lastInspection: '2024-07-15',
      coordinates: { latitude: 36.2048, longitude: 140.1024 },
      species: ['スギ', 'ヒノキ', 'ブナ'],
    },
    {
      id: 2,
      name: '南部森林区域B',
      area: 890,
      treeCount: 2100,
      health: '注意',
      lastInspection: '2024-07-10',
      coordinates: { latitude: 36.1951, longitude: 140.0913 },
      species: ['マツ', 'カシ', 'ナラ'],
    },
    {
      id: 3,
      name: '東部森林区域C',
      area: 670,
      treeCount: 1800,
      health: '要対応',
      lastInspection: '2024-07-05',
      coordinates: { latitude: 36.2145, longitude: 140.1135 },
      species: ['ケヤキ', 'サクラ', 'モミジ'],
    },
  ]);

  const [selectedArea, setSelectedArea] = useState(null);
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

  const mapRef = useRef(null);

  const showToast = (message, type = 'success') => {
    setToast({ show: true, message, type });
    setTimeout(() => {
      setToast({ show: false, message: '', type: '' });
    }, 3000);
  };

  useEffect(() => {
    const loadData = async () => {
      try {
        const savedAreas = await AsyncStorage.getItem('forestAreas');
        if (savedAreas) {
          setForestAreas(JSON.parse(savedAreas));
        }
      } catch (e) {
        console.error('Failed to load forest areas.', e);
      }
    };
    loadData();
  }, []);

  useEffect(() => {
    const saveData = async () => {
      try {
        await AsyncStorage.setItem('forestAreas', JSON.stringify(forestAreas));
      } catch (e) {
        console.error('Failed to save forest areas.', e);
      }
    };
    saveData();
  }, [forestAreas]);

  const mapLayers = {
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
      >
        <UrlTile urlTemplate={mapLayers[mapLayer].url} zIndex={-1} />
        {forestAreas.map((area) => (
          <Marker
            key={area.id}
            coordinate={area.coordinates}
            onPress={() => setSelectedArea(area)}
          >
            <View style={tw`p-3 rounded-full shadow-xl border-2 border-white ${
              area.health === '良好' ? 'bg-green-500' :
              area.health === '注意' ? 'bg-yellow-500' : 'bg-red-500'
            }`}>
              <TreePine size={20} color="white" />
            </View>
          </Marker>
        ))}
      </MapView>
    </View>
  );

  const AreaDetails = ({ area, onEdit, onDelete }) => {
    if (!area) {
      return (
        <View style={tw`bg-white p-6 rounded-lg shadow-lg items-center`}>
          <TreePine size={48} style={tw`text-gray-300 mb-4`} />
          <Text style={tw`text-gray-500 text-center`}>
            地図上の森林区域をタップして詳細情報を表示してください
          </Text>
        </View>
      );
    }

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
        {/* ... other details ... */}
      </View>
    );
  };

  const StatsDashboard = () => {
    const totalArea = forestAreas.reduce((sum, area) => sum + area.area, 0);
    const totalTrees = forestAreas.reduce((sum, area) => sum + area.treeCount, 0);
    const healthyAreas = forestAreas.filter(area => area.health === '良好').length;
    const warningAreas = forestAreas.filter(area => area.health === '注意').length;
    const criticalAreas = forestAreas.filter(area => area.health === '要対応').length;

    return (
      <ScrollView style={tw`p-4`}>
        <View style={tw`grid grid-cols-1 md:grid-cols-2 gap-4`}>
          <View style={tw`bg-white p-4 rounded-lg shadow`}>
            <Text style={tw`text-sm text-gray-600`}>総面積</Text>
            <Text style={tw`text-2xl font-bold text-green-600`}>{totalArea.toLocaleString()} ha</Text>
          </View>
          {/* ... other stats ... */}
        </View>
      </ScrollView>
    );
  };

  const AreasList = () => {
    const filteredAreas = forestAreas.filter(area =>
      area.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      area.species.some(species => species.toLowerCase().includes(searchQuery.toLowerCase()))
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
              {/* ... other area details ... */}
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    );
  };

  const [editingArea, setEditingArea] = useState(null);

  const handleSaveArea = (areaData) => {
    if (editingArea) {
      setForestAreas(forestAreas.map(area => area.id === editingArea.id ? { ...area, ...areaData } : area));
      showToast('森林区域が更新されました。');
    } else {
      const newArea = {
        id: Date.now(),
        ...areaData,
        coordinates: { latitude: mapRegion.latitude, longitude: mapRegion.longitude },
      };
      setForestAreas([...forestAreas, newArea]);
      showToast('新しい森林区域が追加されました。');
    }
    setShowAddForm(false);
    setEditingArea(null);
  };

  const handleDeleteArea = (areaId) => {
    Alert.alert(
      '森林区域の削除',
      'この森林区域を本当に削除しますか？',
      [
        { text: 'キャンセル', style: 'cancel' },
        {
          text: '削除',
          onPress: () => {
            setForestAreas(forestAreas.filter(area => area.id !== areaId));
            setSelectedArea(null);
            showToast('森林区域が削除されました。');
          },
          style: 'destructive',
        },
      ]
    );
  };

  const AreaForm = ({ area, onSave, onCancel }) => {
    const [formData, setFormData] = useState({
      name: area?.name || '',
      area: area?.area?.toString() || '',
      treeCount: area?.treeCount?.toString() || '',
      health: area?.health || '良好',
      lastInspection: area?.lastInspection || new Date().toISOString().split('T')[0],
      species: area?.species?.join(', ') || '',
    });

    const handleChange = (name, value) => {
      setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = () => {
      onSave({
        ...formData,
        area: parseInt(formData.area, 10),
        treeCount: parseInt(formData.treeCount, 10),
        species: formData.species.split(',').map(s => s.trim()),
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
              {/* ... other form fields ... */}
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
            style={tw`flex-row items-center px-3 py-4 border-b-2 ${
              activeTab === id ? 'border-green-500' : 'border-transparent'
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
              <AreaDetails
                area={selectedArea}
                onEdit={() => {
                  setEditingArea(selectedArea);
                  setShowAddForm(true);
                }}
                onDelete={handleDeleteArea}
              />
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
        <View style={tw`absolute bottom-8 right-8 px-6 py-3 rounded-lg shadow-lg ${
          toast.type === 'success' ? 'bg-green-500' : 'bg-red-500'
        }`}>
          <Text style={tw`text-white`}>{toast.message}</Text>
        </View>
      )}
    </SafeAreaView>
  );
};

export default ForestManagementSystem;