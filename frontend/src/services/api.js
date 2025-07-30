import axios from 'axios';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || 'http://localhost:8001';

const api = axios.create({
  baseURL: BACKEND_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use(
  (config) => {
    console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error('API Error:', error);
    if (error.response?.status === 500) {
      alert('サーバーエラーが発生しました。しばらく待ってから再試行してください。');
    }
    return Promise.reject(error);
  }
);

// Tree API
export const treeAPI = {
  getAll: (filters = {}) => {
    const params = new URLSearchParams();
    if (filters.area_id) params.append('area_id', filters.area_id);
    if (filters.health) params.append('health', filters.health);
    return api.get(`/api/trees?${params}`);
  },
  
  getById: (id) => api.get(`/api/trees/${id}`),
  
  create: (treeData) => api.post('/api/trees', treeData),
  
  update: (id, treeData) => api.put(`/api/trees/${id}`, treeData),
  
  delete: (id) => api.delete(`/api/trees/${id}`),
  
  uploadPhoto: (treeId, file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/api/trees/${treeId}/photos`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },
};

// Work Area API
export const workAreaAPI = {
  getAll: () => api.get('/api/work-areas'),
  
  getById: (id) => api.get(`/api/work-areas/${id}`),
  
  create: (areaData) => api.post('/api/work-areas', areaData),
  
  update: (id, areaData) => api.put(`/api/work-areas/${id}`, areaData),
  
  delete: (id) => api.delete(`/api/work-areas/${id}`),
};

// GPS Track API
export const gpsAPI = {
  getAll: (trackType) => {
    const params = trackType ? `?track_type=${trackType}` : '';
    return api.get(`/api/gps-tracks${params}`);
  },
  
  create: (trackData) => api.post('/api/gps-tracks', trackData),
  
  delete: (id) => api.delete(`/api/gps-tracks/${id}`),
};

// Vector Layer API
export const vectorLayerAPI = {
  getAll: () => api.get('/api/vector-layers'),
  
  create: (layerData) => api.post('/api/vector-layers', layerData),
  
  delete: (id) => api.delete(`/api/vector-layers/${id}`),
};

// Measurement API
export const measurementAPI = {
  getAll: () => api.get('/api/measurements'),
  
  create: (measurementData) => api.post('/api/measurements', measurementData),
};

// Analytics API
export const analyticsAPI = {
  getSummary: () => api.get('/api/analytics/summary'),
  
  getSpeciesDistribution: () => api.get('/api/analytics/species-distribution'),
};

// Report API
export const reportAPI = {
  generate: (reportType, areaId = null) => {
    const params = areaId ? `?area_id=${areaId}` : '';
    return api.get(`/api/reports/generate/${reportType}${params}`, {
      responseType: 'blob',
    });
  },
};

// Export API
export const exportAPI = {
  exportData: (format) => {
    return api.get(`/api/export/${format}`, {
      responseType: 'blob',
    });
  },
};

// GSI (国土地理院) Map API utilities
export const mapAPI = {
  getTileUrl: (layer, z, x, y) => {
    const GSI_BASE_URL = process.env.REACT_APP_GSI_API_BASE_URL || 'https://cyberjapandata.gsi.go.jp';
    
    const layerMap = {
      standard: 'std',
      satellite: 'seamlessphoto',
      terrain: 'relief',
      contour: 'gazo4', // 等高線
    };
    
    const layerCode = layerMap[layer] || 'std';
    return `${GSI_BASE_URL}/xyz/${layerCode}/${z}/${x}/${y}.png`;
  },
  
  getElevation: async (lat, lng) => {
    try {
      const GSI_BASE_URL = process.env.REACT_APP_GSI_API_BASE_URL || 'https://cyberjapandata.gsi.go.jp';
      const response = await api.get(
        `${GSI_BASE_URL}/api/elevation?outFormat=JSON&lon=${lng}&lat=${lat}`
      );
      return response.data;
    } catch (error) {
      console.error('Elevation API error:', error);
      return null;
    }
  },
};

// Utility functions
export const downloadBlob = (blob, filename) => {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
};

export const calculateDistance = (lat1, lng1, lat2, lng2) => {
  const R = 6371e3; // metres
  const φ1 = lat1 * Math.PI/180; // φ, λ in radians
  const φ2 = lat2 * Math.PI/180;
  const Δφ = (lat2-lat1) * Math.PI/180;
  const Δλ = (lng2-lng1) * Math.PI/180;

  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
            Math.cos(φ1) * Math.cos(φ2) *
            Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  return R * c; // in metres
};

export const calculatePolygonArea = (coordinates) => {
  // Simple polygon area calculation using shoelace formula
  if (coordinates.length < 3) return 0;
  
  let area = 0;
  for (let i = 0; i < coordinates.length; i++) {
    const j = (i + 1) % coordinates.length;
    area += coordinates[i][0] * coordinates[j][1];
    area -= coordinates[j][0] * coordinates[i][1];
  }
  return Math.abs(area) / 2;
};

export const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

export default api;