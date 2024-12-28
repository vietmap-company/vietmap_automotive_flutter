package vn.vietmap.androidauto.helper

import android.location.Location
import androidx.car.app.model.Distance
import com.mapbox.geojson.Point
import vn.vietmap.vietmapsdk.camera.CameraPosition
import vn.vietmap.vietmapsdk.camera.CameraUpdate
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory
import vn.vietmap.vietmapsdk.camera.CameraUpdateFactory.newLatLngBounds
import vn.vietmap.vietmapsdk.geometry.LatLng
import vn.vietmap.vietmapsdk.geometry.LatLngBounds
import java.util.Locale
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin
import kotlin.math.sqrt

class VietMapNavigationHelper {
    companion object {
        fun buildResetCameraUpdate(): CameraUpdate {
            val resetPosition: CameraPosition =
                CameraPosition.Builder().tilt(0.0).bearing(0.0).build()
            return CameraUpdateFactory.newCameraPosition(resetPosition)
        }

        fun buildOverviewCameraUpdate(
            padding: IntArray, routePoints: List<Point>,
        ): CameraUpdate {
            val routeBounds = convertRoutePointsToLatLngBounds(routePoints)
            return newLatLngBounds(
                routeBounds, padding[0], padding[1], padding[2], padding[3]
            )
        }

        private fun convertRoutePointsToLatLngBounds(routePoints: List<Point>): LatLngBounds {
            val latLngs: MutableList<LatLng> = java.util.ArrayList()
            for (routePoint in routePoints) {
                latLngs.add(LatLng(routePoint.latitude(), routePoint.longitude()))
            }
            return LatLngBounds.Builder().includes(latLngs).build()
        }

        fun calculateDistanceBetween2Point(location1: Location, location2: Location): Double {
            val radius = 6371000.0 // meters

            val dLat = (location2.latitude - location1.latitude) * PI / 180.0
            val dLon = (location2.longitude - location1.longitude) * PI / 180.0

            val a =
                sin(dLat / 2.0) * sin(dLat / 2.0) + cos(location1.latitude * PI / 180.0) * cos(
                    location2.latitude * PI / 180.0
                ) * sin(
                    dLon / 2.0
                ) * sin(dLon / 2.0)
            val c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

            return radius * c
        }

        fun snapLocationToClosestLatLng(targetLocation: LatLng, latLngList: List<LatLng>): LatLng? {
            var closestLatLng: LatLng? = null
            var closestDistance = Double.MAX_VALUE

            for (latLng in latLngList) {
                val distance = calculateHaversineDistance(targetLocation, latLng)
                if (distance < closestDistance) {
                    closestDistance = distance
                    closestLatLng = latLng
                }
            }

            return closestLatLng
        }

        private fun calculateHaversineDistance(point1: LatLng, point2: LatLng): Double {
            val lat1 = Math.toRadians(point1.latitude)
            val lon1 = Math.toRadians(point1.longitude)
            val lat2 = Math.toRadians(point2.latitude)
            val lon2 = Math.toRadians(point2.longitude)

            val dLat = lat2 - lat1
            val dLon = lon2 - lon1

            val a = sin(dLat / 2).pow(2) + cos(lat1) * cos(lat2) * sin(dLon / 2).pow(2)
            val c = 2 * atan2(sqrt(a), sqrt(1 - a))

            // Radius of the Earth in kilometers (mean value)
            val earthRadius = 6371.0
            return earthRadius * c
        }

        fun getDisplayDistance(distance: Double): Distance {
            return if (distance > 1000) {
                Distance.create(distance / 1000, Distance.UNIT_KILOMETERS)
            } else {
                Distance.create(distance, Distance.UNIT_METERS)
            }
        }

        fun getDisplayDuration(durationInMinutes: Double): String {
            return if (durationInMinutes < 60) {
                String.format(Locale.getDefault(), "%.0f phút", durationInMinutes)
            } else if (durationInMinutes < 60 * 24) {
                val hours = durationInMinutes.toInt() / 60
                val minutes = durationInMinutes.toInt() % 60
                String.format(Locale.getDefault(), "%d giờ %d phút", hours, minutes)
            } else {
                val days = durationInMinutes.toInt() / (60 * 24)
                val hours = (durationInMinutes.toInt() % (60 * 24)) / 60
                String.format(Locale.getDefault(), "%d ngày %d giờ", days, hours)
            }
        }
    }
}