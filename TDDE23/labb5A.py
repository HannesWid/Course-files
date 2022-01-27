import cv2
import cvlib
import math
import numpy

chosen_image = 'blommor.jpg'

#5A1
def cvimg_to_list(image):
    """Converts the image to a list of BGR-tuples"""
    lists = []
    for tuples in image:
        for inner_tuples in tuples:
            lists.append(tuple(inner_tuples))
    return lists


def test_img():
    image = cv2.imread(chosen_image)
    print_in_tuples(image)
    list = print_in_tuples(image)
    conv_img = cvlib.rgblist_to_cvimg(list, 405, 720)
    cv2.imshow(" ", conv_img)
    cv2.waitKey(0)
    
#5A2
        
def unsharp_mask(n):
    """Sharpening a given image"""
    return [[gauss(x,y) for x in range(-(n//2), (n - (n//2)))] for y in range(-(n//2), (n - (n//2)))]
    
def gauss(x,y):
    """returns the gaussian value of the given x and y values"""
    if x == 0 and y == 0:
        return 1.5
    return -1/(2*math.pi*(4.5**2))*((math.e**(-((x**2)+(y**2))/(2*(4.5**2)))))

def test_unsharp_mask():
    img = cv2.imread(chosen_image)
    kernel = numpy.array(unsharp_mask(5))
    filtered_img = cv2.filter2D(img, -1, kernel)    
    cv2.imshow("filtered", filtered_img)
    cv2.waitKey(0)
    
