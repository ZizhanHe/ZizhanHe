from sys import platform
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

import os, game_of_life, imageio

# Install Pillow, pathlib, and imageio
 
def text_on_img(filename='01.png', text="Test", size=50, color=(30,144,255)):
    """
    Draw a text on an Image, saves it, show it
    """
    
    fnt = ImageFont.truetype('Courier' if platform == "darwin" else 'cour.ttf', size)
    # create image
    
    lines = text.split('\n')

    pt_to_px = (72 / 96)
    
    # vertical space
    line_spacing_pt = size * 1.35
    line_spacing_px = line_spacing_pt * pt_to_px
    height_px = int(line_spacing_px * len(lines))
    
    if len(lines) == 1:
        height_px += 10
    
    width_px = int(31 * len(lines[0])) # works with font 50pt

    image = Image.new(mode = "RGB", size = (width_px, height_px), color = "white")
    draw = ImageDraw.Draw(image)
    # draw text
    draw.text((10, 0), text, font=fnt, fill=color)
    # save file
    image.save(filename)
    
    # show file
    # os.system(filename)

def generate_imgs(directory, list_of_str):
    """ (str, list) -> NoneType

    Generates images from the text in list_of_str and
    saves them in the directory provided.
    """
    
    for i in range(len(list_of_str)):
        filename = directory + "/" + str(i+1) + ".png"
        text_on_img(filename, list_of_str[i])


def create_gif_from_imgs(directory, gif_filename, frame_duration = 0.5):
    """ (str, str) -> NoneType

    Creates a gif using all the images from the provided
    directory. 
    """
    image_path = Path(directory)
    images = list(image_path.glob('*.png'))
    image_list = []
    
    for file_name in images:
        image_list.append(imageio.imread(file_name))
    
    imageio.mimwrite(gif_filename, image_list, duration = frame_duration)

def create_game_of_life_gif(u, num_of_imgs, directory, gif_name, frame_duration = 0.5):
    """ (list, str) -> NoneType

    Creates n generations of the universe u and the corresponding
    images which will be saved in the directory provided. It then
    creates a gif using the images. The gif is saved using the gif_name
    in the same folder as this python file. 
    
    Note that n is the minimum between num_of_imgs and the period
    of the universe, if the universe has one.
    """
    image_path = Path(directory)
    os.mkdir(image_path)
    
    # generate the text
    lst_of_str = game_of_life.get_n_generations(u, num_of_imgs)
    
    # generate the images
    generate_imgs(directory, lst_of_str)
    
    # create the gif
    create_gif_from_imgs(directory, gif_name, frame_duration)
    
    
if __name__ == "__main__":
    toad = [[0, 1, 0, 0, 1, 0], [0, 0, 1, 1, 0, 0], [0, 1, 1, 1, 0, 0], [0, 1, 0, 0, 1, 0]]
    create_game_of_life_gif(toad, 5, "my_game_of_life_images", "my_game_of_life.gif", frame_duration = 0.5)
    