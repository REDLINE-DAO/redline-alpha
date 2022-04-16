// Simple distance map, returns the distance to the closest object from the position "p"
// in 3d space.

float sdSphere(vec3 p) {
   // A ball with radius 0.05
   return length(p) - 0.25;
}

// Cast a ray starting at "from" and keep going until we hit something or
// run out of iterations.
float ray(vec3 from, vec3 direction) {
    // How far we travelled (so far)
    float travel_distance = 0.0;
    
    for (int i = 0; i < 50; i++) {
        // calculate the current position along the ray
	    vec3 position = from + direction * travel_distance;
	    float distance_to_closest_object = sdSphere(position);
    	if (distance_to_closest_object < 0.01) {
        	return travel_distance;
    	}
        // We can safely advance this far since we know that the closest
        // object is this far away. (But possibly in a completely different
        // direction.)
        travel_distance += distance_to_closest_object;
    }
    
    // We walked 50 steps without hitting anything.
    return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy / 2.0) / iResolution.xx;

    vec3 camera_position = vec3(0, 0, -1);

    // Not that ray_direction needs to be normalized.
    // The "1" here controls the field of view.
    vec3 ray_direction = normalize(vec3(uv, 1));
    
    // Cast a ray, see if we hit anything.
    float t = ray(camera_position, ray_direction);
    
    // Just set the output color to the distance.
	fragColor = vec4(t, t, t, 0);
    //fragColor = vec4(uv, 0., 0.);
}

