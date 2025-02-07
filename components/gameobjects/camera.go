components {
  id: "orbit_camera"
  component: "/scripts/lib/orbit_camera.script"
  properties {
    id: "target"
    value: "/camera_orbit_target"
    type: PROPERTY_TYPE_HASH
  }
  properties {
    id: "distance"
    value: "12.0"
    type: PROPERTY_TYPE_NUMBER
  }
}
embedded_components {
  id: "camera"
  type: "camera"
  data: "aspect_ratio: 1.0\n"
  "fov: 0.6\n"
  "near_z: 0.1\n"
  "far_z: 100.0\n"
  "auto_aspect_ratio: 1\n"
  ""
}
