shader_type canvas_item;

uniform vec2 camera_offset;
uniform float zoom = 1.0;
uniform float grid_size = 50.0;
uniform vec4 dot_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float dot_radius = 0.1;

void fragment() {
    // Получаем реальный размер экрана из встроенной переменной
    vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
    
    // Используем FRAGCOORD — это координаты пикселя от (0,0) до (2560, 1600)
    vec2 pixel_pos = FRAGCOORD.xy;

    // Считаем мировые координаты. 
    // Мы вычитаем половину разрешения, чтобы (0,0) мира был в центре экрана.
    vec2 world_pos = (pixel_pos - screen_res * 0.5) / zoom + camera_offset;

    // Рисуем сетку через fract
    vec2 grid = fract(world_pos / grid_size);
    float dist = distance(grid, vec2(0.5));
    
    // Плавная маска точки. 
    // Коэффициент 0.05 / zoom нужен, чтобы края точек не "лесенкой" при зуме.
    float mask = smoothstep(dot_radius, dot_radius - (0.05 / zoom), dist);
    
    COLOR = vec4(dot_color.rgb, mask * dot_color.a);
}