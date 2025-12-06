-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Work Areas (Forest Zones)
-- Stores polygon data for forest areas.
CREATE TABLE work_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    boundary GEOGRAPHY(POLYGON, 4326) NOT NULL, -- Polygon data
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) -- Owner
);

-- Index for spatial queries
CREATE INDEX work_areas_boundary_idx ON work_areas USING GIST (boundary);

-- 2. Trees
-- Stores individual tree data (Point).
CREATE TABLE trees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    species TEXT NOT NULL, -- e.g., "Cedar", "Cypress"
    height NUMERIC, -- Height in meters
    diameter NUMERIC, -- Diameter at breast height (DBH) in cm
    health_status TEXT, -- e.g., "Healthy", "Damaged"
    location GEOGRAPHY(POINT, 4326) NOT NULL, -- Point data
    photo_url TEXT,
    work_area_id UUID REFERENCES work_areas(id), -- Belongs to an area
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id)
);

-- Index for spatial queries
CREATE INDEX trees_location_idx ON trees USING GIST (location);

-- 3. GPS Tracks (Optional/Future)
-- Stores movement history.
CREATE TABLE gps_tracks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    track_points GEOGRAPHY(LINESTRING, 4326),
    recorded_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id)
);
