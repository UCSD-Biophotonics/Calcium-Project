import numpy
from PIL import Image


class PixelMap:
    def __init__(self, pixels):
        self.pixel_map = []

        for row in pixels:
            self.pixel_map.append([])

            for color in row:
                self.pixel_map[-1].append(color // 100 * 100)

    def _get_threshold(self):
        t = sum(map(sum, self.pixel_map)) / (len(self.pixel_map) * len(self.pixel_map[0]))  # Reference matieral uses T so /shrug

        for _ in range(3):

            upper_pixels = [j for i in self.pixel_map for j in i if j >= t]  # Extremely slow!
            lower_pixels = [j for i in self.pixel_map for j in i if j < t]

            upper_mean = sum(upper_pixels) / len(upper_pixels)
            lower_mean = sum(lower_pixels) / len(lower_pixels)

            t = (upper_mean + lower_mean) / 2
        print(t)
        return t

    def _threshold_map(self, threshold=None):  # TODO - get better name
        if not threshold:
            threshold = self._get_threshold()

        for row in self.pixel_map:
            for i, color in enumerate(row):
                if color < threshold:
                    row[i] = 0
                else:
                    row[i] = 65536

    def _get_neighbors(self, row, col):
        max_row = len(self.pixel_map[0]) - 1
        max_col = len(self.pixel_map) - 1

        neighbors = 0

        for adds in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            row1 = row + adds[0]
            col1 = col + adds[1]

            if row1 < 0 or row1 > max_row or col1 < 0 or col1 > max_col:
                continue

            if self.pixel_map[row1][col1]:
                neighbors += 1
        return neighbors

    def _smooth_cells(self):
        height = len(self.pixel_map)
        width = len(self.pixel_map[0])

        change = True  # TODO - see if while true or just repeat 3 times
        while change:
            change = False
            for row in range(height):
                for col in range(width):
                    if self.pixel_map[row][col] and self._get_neighbors(row, col) <= 1:
                        self.pixel_map[row][col] = 0
                        change = True

        for _ in range(3):
            for row in range(height):
                for col in range(width):
                    if not self.pixel_map[row][col] and self._get_neighbors(row, col) >= 3:
                        self.pixel_map[row][col] = 65536

    def _is_edge(self, row, col):
        max_row = len(self.pixel_map[0]) - 1
        max_col = len(self.pixel_map) - 1

        for add in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            row1 = row + add[0]
            col1 = col + add[1]

            if row1 < 0 or row1 > max_row or col1 < 0 or col1 > max_col:
                continue

            if not self.pixel_map[row1][col1]:
                return True
        return False

    def _get_edges(self):
        edges = [[0 for _ in i] for i in self.pixel_map]

        for i, row in enumerate(edges):
            for j, col in enumerate(row):
                if not self.pixel_map[i][j]:
                    continue

                if self._is_edge(i, j):
                    edges[i][j] = 65536

        return edges

    def _get_directions(self, current, parent):
        cc_layout = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]

        if parent[0] == -1:
            return cc_layout
        else:
            temp = parent[0] - current[0], parent[1] - current[1]
            i = cc_layout.index(temp)

            return cc_layout[i:] + cc_layout[:i]

    def _get_outline(self, coords, edges):
        parent = (-1, -1)
        outline = [coords]
        max_row = len(edges) - 1
        max_col = len(edges[0]) - 1

        finished = False
        while not finished:
            # print(coords)

            for add in self._get_directions(coords, parent):
                row1 = coords[0] + add[0]
                col1 = coords[1] + add[1]

                # print(add)

                if row1 < 0 or row1 > max_row or col1 < 0 or col1 > max_col:
                    continue

                if row1 == parent[0] and col1 == parent[1]:
                    continue

                if edges[row1][col1]:
                    if row1 == outline[0][0] and col1 == outline[0][1]:
                        finished = True
                    else:
                        parent = coords
                        coords = (row1, col1)

                        outline.append((row1, col1))
                    break
            else:
                break

        print(outline)
        if len(outline) > 0:
            Image.fromarray(numpy.array(edges)).show()

        return outline

    def _get_rois(self):
        edges = self._get_edges()
        outlines = []

        for i in range(len(edges)):
            for j in range(len(edges[0])):
                if edges[i][j]:
                    outlines.append(self._get_outline((i, j), edges))

                    for coord in outlines[-1]:
                        edges[coord[0]][coord[1]] = 0

        return list(filter(lambda x: len(x) > 10, outlines))


    def save_image(self):  # FOR DEBUGGING
        temp_im = Image.fromarray(numpy.array(self.pixel_map))
        temp_im.save("test.png")


image_path = r"C:\Users\chris\IdeaProjects\tether-project\Calcium Project\ImageAnalysis1\GFP\05_09_19_13h20m_55s_ms005__E157.tif"

im = Image.open(image_path)
arr = numpy.array(im)

map_ = PixelMap(arr)
map_._threshold_map(threshold=9148.427826675175)
map_._smooth_cells()
print(map_._get_rois())

map_.save_image()
