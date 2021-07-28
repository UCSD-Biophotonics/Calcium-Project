import numpy
from PIL import Image


class PixelMap:
    def __init__(self, pixels):
        self.pixel_map = []

        for i, row in enumerate(pixels):
            self.pixel_map.append([])

            for j, color in enumerate(row):
                self.pixel_map[-1].append(Pixel((i, j), color))

    def _threshold_map(self, lower_bound=.6):
        # not a good way to do thresholding but oh well

        largest = max(map(lambda x: max(map(lambda y: y.color, x)), self.pixel_map))
        bound = largest * lower_bound

        for row in self.pixel_map:
            for i in row:
                if i.color < bound:
                    i.color = 0

    def _trim_outliers(self):
        pass
        # TODO - implement

    def _get_rois(self):
        pass
        # TODO - implement

    def to_array(self):
        return [[j.color for j in i] for i in self.pixel_map]

    def show_image(self):
        temp_im = Image.fromarray(numpy.array(self.to_array()))
        temp_im.show()


class Pixel: # Shitty use of a class but oh well
    def __init__(self, coords, color):
        self.coords = coords
        self.color = color

        self.region_size = -1
        self.num_neighbors = -1


image_path = r"C:\Users\chris\IdeaProjects\tether-project\Calcium Project\ImageAnalysis1\GFP\05_09_19_13h20m_55s_ms005__E157.tif"

im = Image.open(image_path)
arr = numpy.array(im)

map_ = PixelMap(arr)
map_._threshold_map()

map_.show_image()
