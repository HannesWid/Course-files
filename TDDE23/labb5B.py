import cvlib
import cv2
import numpy
import labb5A
import random

#LABB 5B1

def pixel_constraint(hlow, hhigh, slow, shigh, vlow, vhigh):
    """Returns a function that checks if a pixel is within the defined range"""
    def pixel_black(v):
        if v[0] > hlow and v[0] < hhigh and \
            v[1] > slow and v[1] < shigh and \
            v[2] > vlow and v[2] < vhigh:
            return 1
        else:
            return 0
    return pixel_black


def test_plane():
    hsv_plane = cv2.cvtColor(cv2.imread("plane.jpg"), cv2.COLOR_BGR2HSV)
    plane_list = labb5A.cvimg_to_list(hsv_plane)

    is_sky = pixel_constraint(100, 150, 50, 200, 100, 255)
    sky_pixels = list(map(lambda x: x * 255, map(is_sky, plane_list)))

    cv2.imshow('sky', cvlib.greyscale_list_to_cvimg(sky_pixels, hsv_plane.shape[0], hsv_plane.shape[1]))
    cv2.waitKey(0)


#LABB 5B2

def generator_from_image(image):
    """Returns a function that given an index returns a pixel in a tuple""" 
    def image_pixel(index):
        return image[index]
    return image_pixel
   
def test_generator():
    orig_img = cv2.imread("plane.jpg")
    orig_list = labb5A.cvimg_to_list(orig_img)
    generator = generator_from_image(orig_list)
    new_list = [generator(i) for i in range(len(orig_list))]
    cv2.imshow('original', orig_img)
    cv2.imshow('new', cvlib.rgblist_to_cvimg(new_list, orig_img.shape[0], orig_img.shape[1]))
    cv2.waitKey(0)


#LABB 5B3

def combine_images(tuple_list, condition, generator1, generator2):
    """Given 2 image lists, combines them into 1 given a certain condition."""
    new_list = []
    tuples = generator_from_image(tuple_list)
    for i in range(len(tuple_list)):
        tuple_1 = (generator1(i))
        tuple_2 = (generator2(i))
        c_value = condition(tuples(i))
        tuple_combined = (tuple_1[0] * c_value + tuple_2[0] * (1 - c_value),\
                         tuple_1[1] * c_value+ tuple_2[1] * (1 - c_value),\
                         tuple_1[2] * c_value+ tuple_2[2] * (1 - c_value))
        new_list.append(tuple_combined)
    return new_list

def test_combine_images():
    plane_img = cv2.imread("plane.jpg")

    # Skapa ett filter som identifierar himlen
    condition = pixel_constraint(100, 150, 50, 200, 100, 255)

    # Omvandla originalbilden till en lista med HSV-färger
    hsv_list = labb5A.cvimg_to_list(cv2.cvtColor(plane_img, cv2.COLOR_BGR2HSV))
    plane_img_list = labb5A.cvimg_to_list(plane_img)

    # Skapa en generator som gör en stjärnhimmel
    def generator1(index):
        val = random.random() * 255 if random.random() > 0.99 else 0
        return (val, val, val)

    # Skapa en generator för den inlästa bilden
    generator2 = generator_from_image(plane_img_list)

    # Kombinera de två bilderna till en, alltså använd himmelsfiltret som mask
    result = combine_images(hsv_list, condition, generator1, generator2)

    # Omvandla resultatet till en riktig bild och visa upp den
    new_img = cvlib.rgblist_to_cvimg(result, plane_img.shape[0], plane_img.shape[1])
    cv2.imshow('Final image', new_img)
    cv2.waitKey(0)

#LABB 5B4

def gradient_condition(bgr):
    """Returns a value between 0 and 1 based on the grey scale."""
    value = 0
    for i in bgr:
        value += i
    return (value / 765)


def test_gradient():
    new_list= []
    flower_img = cv2.imread("flowers.jpg")
    flower_img_list = labb5A.cvimg_to_list(flower_img)
    generator_flower = generator_from_image(flower_img_list)

    plane_img = cv2.imread("plane.jpg")
    plane_img_list = labb5A.cvimg_to_list(plane_img)
    generator_plane = generator_from_image(plane_img_list)


    gradient_img = cv2.imread("gradient.jpg")
    gradient_img_list = labb5A.cvimg_to_list(gradient_img)

    new_list = combine_images(gradient_img_list, gradient_condition, generator_flower, generator_plane)
    new_img = cvlib.rgblist_to_cvimg(new_list, gradient_img.shape[0], gradient_img.shape[1])
    cv2.imshow('Final image', new_img)
    cv2.waitKey(0)



    
