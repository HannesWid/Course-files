import labb5B
import cv2
import cvlib
import labb5A
import random

#LABB 5C1

def test_pixel_constraint():
    test_func = pixel_constraint(50, 100, 200, 250, 50, 150)
    #Testing expected true/1 value
    assert test_func((75, 225, 100)) == 1
    #Testing expected false/0 value
    assert test_func((25, 220, 100)) == 0
    #Testing lower limit
    assert test_func((50, 220, 60)) == 0
    test_func = pixel_constraint(80, 120, 200, 210, 50, 90)
    #Testing higher limit
    assert test_func((120, 205, 85)) == 0
    #Testing negative value
    assert test_func((-100, 209, 85)) == 0
    #Testing float value
    assert test_func((81.12, 201, 51)) == 1
    print("The code passed all tests")

def test_generator_from_image():
    test_generator_1 = [(1,2,3),(4,5,6),(7,8,9)]
    test_generator_2 = [(201.55,202,303.12),(182.2, 190, 150)]
    test_1_list = []
    test_generator = generator_from_image(test_generator_1)
    #Tests value of first tuple from generated list
    assert test_generator(0) == test_generator_1[0]
    #Compares the original list and generated list from the function
    assert test_generator_1 == [test_generator(i) for i in range(len(test_generator_1))]
    test_generator = generator_from_image(test_generator_2)
    #Tests value of first tuple with float value from generated list
    assert test_generator(0) == test_generator_2[0]
    #Compares list of tuples with float values to the generated list from the function
    assert test_generator_2 == [test_generator(i) for i in range(len(test_generator_2))]
    print("The code passed all tests")

def test_combine_image():
    test_list = [(1,2,3),(2,2,1),(4,4,4),(4,4,5)]
    expected_list = [(2,2,2), (1,1,1), (2,2,2), (1,1,1)]
    def condition(tuples):
        sum = 0
        for elements in tuples:
            sum += elements
        if sum%2 == 0:
            return 1
        else: return 0
    def generator1(i):
        return (2,2,2)
    def generator2(i):
        return(1,1,1)
    #Compares the expected list to the generated list
    assert labb5B.combine_images(test_list, condition, generator1, generator2) \
           == expected_list
    print("The code passed all tests")

#Labb 5C2

def generator_from_image(image):
    """Returns a function that given an index returns a pixel in a tuple"""
    def image_pixel(index):
        try:
            return image[index]
        except Exception as exc:
            raise IndexError("Index not in list") from exc
    return image_pixel

def generator_from_images_exception():
    """Tests if the function with an index out or range throws an exception"""
    test_list = [(1,2,3),(3,2,2),(5,4,5)]
    generator = generator_from_image(test_list)
    generator(5)

def generator_from_image_raise_error():
    """Tests if the inner function with an index out of range, throws an exception that is catched by the exception"""
    try:
        generator_from_images_exception()
    except IndexError:
        print("Index not in list")

def pixel_constraint(hlow, hhigh, slow, shigh, vlow, vhigh):
    """Returns a function that checks if a pixel is within the defined range"""
    def pixel_black(v):
        try:
            if v[0] > hlow and v[0] < hhigh and \
                v[1] > slow and v[1] < shigh and \
                v[2] > vlow and v[2] < vhigh:
                return 1
            else:
                return 0
        except Exception as exc:
                raise TypeError("Values can not be interpreted as a hsv/bgr-tuple") from exc
    return pixel_black

def pixel_constraint_exception():
    """Tests if the function with an input that cannot be interpreted as a hsv/bgr-tuple, throws an exception"""
    generator = pixel_constraint(0, 100, 0, 100, 0 , 100)
    generator(("HEJ", 4, 6))

def pixel_constraint_raise_error():
    """Tests if the function raises a TypeError that is catched by the exception"""
    try:
        pixel_constraint_exception()
    except TypeError:
        print("Values can not be interpreted as a hsv/bgr-tuple")

def combine_images(tuple_list, condition, generator1, generator2):
    """Given 2 image lists, combines them into 1 given a certain condition."""
    new_list = []
    tuples = generator_from_image(tuple_list)
    try:
        for i in range(len(tuple_list)):
                tuple_1 = (generator1(i))
                tuple_2 = (generator2(i))
                c_value = condition(tuples(i))
                tuple_combined = (tuple_1[0] * c_value + tuple_2[0] * (1 - c_value),\
                                  tuple_1[1] * c_value+ tuple_2[1] * (1 - c_value),\
                                  tuple_1[2] * c_value+ tuple_2[2] * (1 - c_value))
                new_list.append(tuple_combined)
    except TypeError:
        print("Values can not be interpreted as a hsv/bgr-tuple")
    except IndexError:
        print("Index out of range")
    return new_list


    
