package vn.vietmap.androidauto

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.ScreenManager
import androidx.car.app.SurfaceCallback
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarColor
import androidx.car.app.model.CarIcon
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.core.graphics.drawable.IconCompat
import okhttp3.internal.toHexString
import vn.vietmap.vietmapandroidautosdk.map.VietMapAndroidAutoSurface
import vn.vietmap.vietmapsdk.R
import vn.vietmap.vietmapsdk.annotations.IconFactory
import vn.vietmap.vietmapsdk.annotations.Marker
import vn.vietmap.vietmapsdk.annotations.MarkerOptions
import vn.vietmap.vietmapsdk.annotations.Polygon
import vn.vietmap.vietmapsdk.annotations.PolygonOptions
import vn.vietmap.vietmapsdk.annotations.Polyline
import vn.vietmap.vietmapsdk.annotations.PolylineOptions
import vn.vietmap.vietmapsdk.geometry.LatLng
import vn.vietmap.vietmapsdk.maps.OnMapReadyCallback
import vn.vietmap.vietmapsdk.maps.Style
import vn.vietmap.vietmapsdk.maps.VietMapGL

class VietMapCarAppScreen(
    carContext: CarContext,
      val mSurfaceRenderer: VietMapAndroidAutoSurface,
) : Screen(carContext) {

    private var vietmapGL: VietMapGL? = null
    private var apikey: String? = null

    private val listMarkers: ArrayList<Marker> = ArrayList()
    private val listPolylines: ArrayList<Polyline> = ArrayList()
    private val listPolygons: ArrayList<Polygon> = ArrayList()

    private val mSurfaceCallback: SurfaceCallback = object : SurfaceCallback {
        // Handle surface callback event here
    }

    init {
//        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder(),
            OnMapReadyCallback {
                vietmapGL = it
            }
        )
    }
    fun init(styleUrl: String, apiKey: String) {
        this.apikey = apiKey
        mSurfaceRenderer.addOnSurfaceCallbackListener(mSurfaceCallback)
        mSurfaceRenderer.init(
            Style.Builder()
                .fromUri(styleUrl),
            {
                Log.d("VietMapCarAppScreen", "Style loaded")
            },
            {
                vietmapGL = it
                invalidate()
            }
        )
        invalidate()
    }

    override fun onGetTemplate(): Template {
        val builder = NavigationTemplate.Builder()
        builder.setBackgroundColor(CarColor.SECONDARY)

        // Set the action strip.
        val actionStripBuilder = ActionStrip.Builder()
        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Back")
                .setIcon(
                    CarIcon.Builder(
                        IconCompat.createWithResource(
                            carContext,
                            vn.vietmap.vietmapsdk.R.drawable.vietmap_logo_icon
                        )
                    ).build()
                ).setOnClickListener {
                    val screenManager: ScreenManager =
                        carContext.getCarService(ScreenManager::class.java)
                    screenManager.pop()
                }
                .build()
        )

        builder.setActionStrip(actionStripBuilder.build())

        // Set the map action strip
        val panIconBuilder = CarIcon.Builder(
            IconCompat.createWithResource(
                carContext,
                vn.vietmap.vietmapsdk.R.drawable.vietmap_compass_icon
            )
        )
        builder.setMapActionStrip(
            ActionStrip.Builder()
                .addAction(
                    Action.Builder(Action.PAN)
                        .setIcon(panIconBuilder.build())
                        .build()
                )
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    vn.vietmap.vietmapsdk.R.drawable.vietmap_compass_icon
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            //TODO: Add your code here
                        }
                        .build())
                .addAction(
                    Action.Builder()
                        .setIcon(
                            CarIcon.Builder(
                                IconCompat.createWithResource(
                                    carContext,
                                    vn.vietmap.vietmapsdk.R.drawable.vietmap_logo_icon
                                )
                            )
                                .build()
                        )
                        .setOnClickListener {
                            //TODO: Add your code here
                        }
                        .build())
                .build())

        return builder.build()
    }


    fun addMarker(data: List<Map<String,Any>>) : ArrayList<Long> {
        val listMarkerId = ArrayList<Long>()
        try {
            data.forEach {
                try{
                    val d = it
                    val latitude = d["lat"] as? Double ?: return@forEach
                    val longitude = d["lng"] as? Double ?: return@forEach
                    val position = LatLng(latitude, longitude)
                    val title = d["title"] as? String ?: ""
                    val snippet = d["snippet"] as? String ?: ""
                    val base64Encoded = d["base64Encoded"] as? String
                    val width = d["width"] as? Int
                    val height = d["height"] as? Int

                    val iconBitmap = base64Encoded?.let {
                        val decodedString = android.util.Base64.decode(it, android.util.Base64.DEFAULT)
                        BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
                    }

                    val scaledBitmap = if (iconBitmap != null && width != null && height != null) {
                        Bitmap.createScaledBitmap(iconBitmap, width, height, false)
                    } else {
                        iconBitmap
                    }

                    val icon = scaledBitmap?.let {
                        scaledBM->
                        IconFactory.getInstance(carContext).fromBitmap(scaledBM)
                    }

                    val markerOption = MarkerOptions()
                        .icon(icon)
                        .title(title)
                        .snippet(snippet)
                        .position(position)

                    val marker = vietmapGL?.addMarker(markerOption)

                    marker?.let {m ->
                        listMarkerId.add(m.id)
                        listMarkers.add(m)
                    }
                }
                catch(e: Exception) {
                    e.printStackTrace()
                }
            }

            return listMarkerId
        } catch (e: Exception) {
            e.printStackTrace()
            return listMarkerId
        }
    }

    fun removeMarker(data: Map<String, Any>) : Boolean {
        val markersIdList = data["markerIds"] as ArrayList<Int>
        try {
            markersIdList.forEach { markerId ->
                val temp = ArrayList<Marker>()
                listMarkers.forEach {
                    if (it.id == markerId.toLong()) {
                        it.remove()
                        temp.add(it)
                    }
                }
                listMarkers.removeAll(temp.toSet())
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllMarkers() : Boolean {
        try {
            listMarkers.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun addPolylines(mapData: Map<String, Any>) : ArrayList<Long> {
        val polylineIds = ArrayList<Long>()
        try{
            val polylineList = mapData["polylines"] as List<Map<String, Any>>
            polylineList.forEach { data ->
                try {
                    val points = data["points"] as List<Map<String, Double>>
                    val latLngList = ArrayList<LatLng>()
                    points.forEach {
                        val lat = it["lat"] as Double
                        val lng = it["lng"] as Double
                        latLngList.add(LatLng(lat, lng))
                    }
                    val polylineColor = data["color"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"

                    val polylineOptions = PolylineOptions().let {
                        it.addAll(latLngList)
                        it.color(Color.parseColor(polylineColor))
                        it.width(data["width"] as? Float? ?: 10.0f)
                        it.alpha(data["alpha"] as? Float? ?: 1.0f)
                        it
                    }

                    val polyline = vietmapGL?.addPolyline(polylineOptions)
                    polyline?.let { p ->
                        polylineIds.add(p.id)
                        listPolylines.add(p)
                    }
                }
                catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return polylineIds
        }
        catch (e: Exception) {
            e.printStackTrace()
            return polylineIds
        }
    }

    fun removePolyline(data: Map<String, Any>) : Boolean {
        val polylineIds = data["polylineIds"] as ArrayList<Long>
        try {
            val temp = ArrayList<Polyline>()
            polylineIds.forEach { polylineId ->
                listPolylines.forEach {
                    if (it.id == polylineId) {
                        it.remove()
                        temp.add(it)
                    }
                }
            }
            listPolylines.removeAll(temp.toSet())
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllPolylines() : Boolean {
        try {
            listPolylines.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun addPolygons(mapData: Map<String, Any>) : ArrayList<Long> {
        val polygonIds = ArrayList<Long>()
        try{
            val polygonList = mapData["polygons"] as List<Map<String, Any>>
            polygonList.forEach { data ->
                try {
                    val points = data["points"] as List<Map<String, Double>>
                    val holes = data["holes"] as List<List<Map<String, Double>>>
                    val pointLatLngList = ArrayList<LatLng>()
                    val holeLatLngList = ArrayList<List<LatLng>>()

                    points.forEach {
                        val lat = it["lat"] as Double
                        val lng = it["lng"] as Double
                        pointLatLngList.add(LatLng(lat, lng))
                    }

                    holes.forEach { hole ->
                        val holeList = ArrayList<LatLng>()
                        hole.forEach {
                            val lat = it["lat"] as Double
                            val lng = it["lng"] as Double
                            holeList.add(LatLng(lat, lng))
                        }
                        holeLatLngList.add(holeList)
                    }

                    val fillColor = data["fillColor"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"
                    val strokeColor = data["strokeColor"] as? String? ?: "#${R.color.vietmap_blue.toHexString()}"

                    val polygonOptions = PolygonOptions().let {
                        it.addAll(pointLatLngList)
                        it.fillColor(Color.parseColor(fillColor))
                        it.strokeColor(Color.parseColor(strokeColor))
                        it.alpha(data["alpha"] as? Float? ?: 1.0f)
                        it.addAllHoles(holeLatLngList)
                        it
                    }

                    val polygon = vietmapGL?.addPolygon(polygonOptions)
                    polygon?.let { p ->
                        polygonIds.add(p.id)
                        listPolygons.add(p)
                    }
                }
                catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return polygonIds
        }
        catch (e: Exception) {
            e.printStackTrace()
            return polygonIds
        }
    }

    fun removePolygon(data: Map<String, Any>) : Boolean {
        val polygonIds = data["polygonIds"] as ArrayList<Long>
        try {
            val temp = ArrayList<Polygon>()
            polygonIds.forEach { polygonId ->
                listPolygons.forEach {
                    if (it.id == polygonId) {
                        it.remove()
                        temp.add(it)
                    }
                }
            }
            listPolygons.removeAll(temp.toSet())
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    fun removeAllPolygons() : Boolean {
        try {
            listPolygons.forEach {
                it.remove()
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }
}