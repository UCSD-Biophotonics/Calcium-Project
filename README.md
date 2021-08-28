# Calcium Image Analysis Project

The Calcium Image Analysis Project is an app developed in MATLAB that aims to analyze the intensities of calcium cells.

# Usage
Make sure you have the [Image processing Toolbox](https://www.mathworks.com/products/image.html) and [Signal Processing Toolbox](https://www.mathworks.com/products/signal.html) installed from the MATLAB packaging.

1. Click the Load File Button

![Load File Image](/Screenshots/1.png)

2. Select the folder one file outside the GFP folder

![File Location Image](/Screenshots/2.png)

3. (Optional) Check the TOM checkbox in the menu if there is a TOM file

![TOM Image](/Screenshots/3.png)

4. Press the Add Cell button or press "1" on the keyboard to bring up the Cell Selection UI ("2" on the keyboard brings up a predefined Circle Creator and a "3" on the keyboard brings up a predefined Rectangle Creator for easier access)

5. Outline each of the cells

6. Outline the background of the image last, making sure to select an area without any cells

![ROI selection Image](/Screenshots/4.png)

7. Press the Get Intensities button

![Get Intensities Image](/Screenshots/5.png)

8. Enter the last two numbers of the year the data is from (i.e. 2019 --> "19")

![Year Selection Image](/Screenshots/6.png)

9. Add the cut numbers and plateau range after peaks to their respective text editors

![Cut Numbers Settings Image](/Screenshots/7.png)

10. Press the Popup and Halflife button

![Popup and Halflife Image](/Screenshots/8.png)

11. Change tabs to Extract Peak Parameters

![Extract Peak Parameters Image](/Screenshots/9.png)

12. (Optional) Change the settings as needed

13. Press Run

14. Check the accuracy of the graphs

![Graphs Image](/Screenshots/10.png)
![Graphs Image](/Screenshots/11.png)
![Graphs Image](/Screenshots/12.png)

15. Change dropdown value from Display to Write to Output

![Dropdown Image](/Screenshots/13.png)

16. Press Run
