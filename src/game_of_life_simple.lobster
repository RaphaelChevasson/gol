import vec
import color
import gl

gl.window("Game Of Life", 1280, 720)
let grid_size = int2 { 16, 9 } * 20
let wrap_around = false

let color_dark = color { 0.1, 0.1, 0.1, 1.0 }
let color_light = color { 0.9, 0.9, 0.9, 1.0 }

let neighbor_directions = [].append(cardinal_directions).append(diagonal_directions)
let grid = mapxy(grid_size): rnd_float() < 0.1
def reset(): forxy(grid_size): grid[_] = rnd_float() < 0.1
let old_grid = mapxy(grid_size): false

def modulo(x, n): return (x % n + n) % n // in [0,n[ range, contrary to % which can be negative
def isin(ij, size): return all(ij >= int2_0) and all(ij < size)

def isalive(on_grid, ij):
    var n_alive_neighbors = 0
    if wrap_around:
        for(neighbor_directions) dir:
            n_alive_neighbors += on_grid[modulo(ij + dir, grid_size)]
    else:
        for(neighbor_directions) dir:
            if isin(ij + dir, grid_size):
                n_alive_neighbors += on_grid[ij + dir]
    return switch n_alive_neighbors:
        case 2: on_grid[ij]
        case 3: true
        default: false

while gl.frame() and not gl.button("escape"):
    // sim
    forxy(grid_size) ij:
        old_grid[ij] = grid[ij]
    
    forxy(grid_size) ij:
        grid[ij] = isalive(old_grid, ij)

    // inputs: mouse draws alive (left click) or dead (right click) cells, `R` randomize the grid
    let mouse_ij = gl.mouse_pos(0) * grid_size / gl.window_size()
    if gl.button("mouse1"):
        grid[mouse_ij] = true
    if gl.button("mouse3"): // right button
        grid[mouse_ij] = false
    
    if gl.button("r"):
        reset()

    // draw the grid
    gl.clear color_dark
    gl.scale(float(gl.window_size()) / float(grid_size))

    forxy(grid_size) ij:
        let alive_color = lerp(color_dark, color_light, grid[ij])
        gl.color alive_color
        gl.translate ij:
            gl.unit_square()
