class Point3D {
  double x;
  double y;
  double z;

  Point3D(this.x, this.y, this.z);

  // Vector subtraction: returns a new Point3D representing the vector from 'other' to 'this'
  Point3D operator -(Point3D other) {
    return Point3D(
      x - other.x,
      y - other.y,
      z - other.z,
    );
  }

  // Cross product: returns a new Point3D that is the cross product of 'this' and 'other'
  Point3D cross(Point3D other) {
    return Point3D(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  // Dot product: returns the scalar dot product of 'this' and 'other'
  double dot(Point3D other) {
    return x * other.x + y * other.y + z * other.z;
  }
}
