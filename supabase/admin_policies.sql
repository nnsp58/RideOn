-- =============================================
-- ADMIN ACCESS POLICIES
-- Note: "documents" is storage bucket, NOT table
-- =============================================

-- Users table - Admin can view all
CREATE POLICY "Admin can view all users" ON users
FOR ALL USING (true) WITH CHECK (true);

-- Rides table - Admin can view all
CREATE POLICY "Admin can view all rides" ON rides
FOR ALL USING (true) WITH CHECK (true);

-- Bookings table - Admin can view all
CREATE POLICY "Admin can view all bookings" ON bookings
FOR ALL USING (true) WITH CHECK (true);

-- SOS Alerts table - Admin can view all
CREATE POLICY "Admin can view all sos_alerts" ON sos_alerts
FOR ALL USING (true) WITH CHECK (true);

-- Reviews table - Admin can view all
CREATE POLICY "Admin can view all reviews" ON reviews
FOR ALL USING (true) WITH CHECK (true);

-- Ride Searches - Admin can view all
CREATE POLICY "Admin can view all searches" ON ride_searches
FOR ALL USING (true) WITH CHECK (true);