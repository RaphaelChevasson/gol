import std
import vec
import color
import gl
import texture

gl.window("Game Of Life", 1280, 720)
let grid_size = int2 { 16, 9 } * 20
let wrap_around = false
let bug_double_buffering = false
let render_squares_one_by_one = true // seems there is no texture.set(buffer), so this will have to do

let color_dark = color { 0.1, 0.1, 0.1, 1.0 }
let color_light = color { 0.9, 0.9, 0.9, 1.0 }

let neighbor_directions = [].append(cardinal_directions).append(diagonal_directions)
let grid = map(grid_size.x * grid_size.y): rnd_float() < 0.1
def reset(): forxy(grid_size): grid[idx(_)] = rnd_float() < 0.1
let old_grid =
    if bug_double_buffering:
        grid // points to the same object, defeating our double buffering
    else:
        map(grid_size.x * grid_size.y): false
/*if not render_squares_one_by_one:
    var grid_texture = gl.create_texture_single_channel(mapxy(grid_size): 0, texture_format_writeonly | texture_format_nearest_mag)*/

def idx(x, y): return x + y * grid_size.x
def idx(v): return idx(v.x, v.y)
def modulo(x, n): return (x % n + n) % n // in [0,n[ range, contrary to % which can be negative
def isin(ij, size): return all(ij >= int2_0) and all(ij < size)

def isalive(ij):
    var n_alive_neighbors = 0
    if wrap_around:
        for(neighbor_directions) dir:
            n_alive_neighbors += old_grid[idx(modulo(ij + dir, grid_size))]
    else:
        for(neighbor_directions) dir:
            if isin(ij + dir, grid_size):
                n_alive_neighbors += old_grid[idx(ij + dir)]
    return switch n_alive_neighbors:
        case 0, 1: false
        case 2: old_grid[idx(ij)]
        case 3: true
        default: false

var paused = false

while gl.frame() and not gl.button("escape"):

    // keyboard inputs
    if gl.button("space") == 1: // first press only
        paused = not paused
    
    if gl.button("r"):
        reset()
    
    // sim
    if not paused:
        for(grid) e, i:
            old_grid[i] = e // = grid[i]
        forxy(grid_size) ij:
            grid[idx(ij)] = isalive(ij)

    // mouse inputs: draws alive (left click) or dead (right click) cells
    let mouse_ij = gl.mouse_pos(0) * grid_size / gl.window_size()
    if gl.button("mouse1"):
        grid[idx(mouse_ij)] = true
    if gl.button("mouse3"): // right button
        grid[idx(mouse_ij)] = false

    // draw the grid
    gl.clear color_dark
    let scale = float(gl.window_size()) / float(grid_size)
    gl.scale scale

    assert render_squares_one_by_one // else: not implemented
    forxy(grid_size) ij:
        //let checker_color = lerp(color_white, color_dark, (ij.x + ij.y) % 2)
        let alive_color = lerp(color_dark, color_light, grid[idx(ij)])
        gl.color  alive_color
        gl.translate ij:
            gl.unit_square()
