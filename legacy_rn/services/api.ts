import { Platform } from 'react-native';

// Android emulator requires 10.0.2.2 to access host localhost
const API_URL = Platform.OS === 'android'
  ? 'http://10.0.2.2:8001/api'
  : 'http://localhost:8001/api';

export const api = {
  // Forest Areas
  getForestAreas: async () => {
    const response = await fetch(`${API_URL}/work-areas`);
    if (!response.ok) throw new Error('Failed to fetch forest areas');
    return response.json();
  },

  createForestArea: async (areaData: any) => {
    // Transform frontend model to backend model if necessary
    // Backend expects: name, status, boundary (List[List[float]]), description
    // Frontend provides: name, area, treeCount, health, species, coordinates

    // For now, we'll map what we can and use description for extras
    const payload = {
      name: areaData.name,
      status: areaData.health === '良好' ? 'active' : 'maintenance',
      boundary: [], // We don't have boundary points in the simple form yet
      description: JSON.stringify({
        area: areaData.area,
        species: areaData.species,
        health: areaData.health,
        coordinates: areaData.coordinates
      })
    };

    const response = await fetch(`${API_URL}/work-areas`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!response.ok) throw new Error('Failed to create forest area');
    return response.json();
  },

  updateForestArea: async (id: string, areaData: any) => {
    const payload = {
      name: areaData.name,
      status: areaData.health === '良好' ? 'active' : 'maintenance',
      description: JSON.stringify({
        area: areaData.area,
        species: areaData.species,
        health: areaData.health,
        coordinates: areaData.coordinates
      })
    };

    const response = await fetch(`${API_URL}/work-areas/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (!response.ok) throw new Error('Failed to update forest area');
    return response.json();
  },

  deleteForestArea: async (id: string) => {
    const response = await fetch(`${API_URL}/work-areas/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Failed to delete forest area');
    return response.json();
  },

  // Trees
  getTrees: async () => {
    const response = await fetch(`${API_URL}/trees`);
    if (!response.ok) throw new Error('Failed to fetch trees');
    return response.json();
  },

  uploadTreePhoto: async (treeId: string, photo: any) => {
    const formData = new FormData();
    formData.append('file', {
      uri: photo.uri,
      type: photo.type || 'image/jpeg',
      name: photo.fileName || 'photo.jpg',
    });

    const response = await fetch(`${API_URL}/trees/${treeId}/photos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      body: formData,
    });

    if (!response.ok) throw new Error('Failed to upload photo');
    return response.json();
  },
};
