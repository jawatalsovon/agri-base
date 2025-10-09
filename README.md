# YOUR PROJECT TITLE
#### Video Demo:  https://youtu.be/kCPsaXMOU-8?si=847LGnc8TpdEF4ku
#### Description:
   AgriBase is a web app with flask in the backend. I have implemented the data from the National Yearbook of Agricultural Statistics of my Country, Bangladesh, in the project.

   I got the yearbook as a large pdf file of 696 pages. It contains hundreds of tables and charts. Searching for any specific desired data can be troublesome for us all. That is why I took this project to make the data more accessible to everyone.
   I first extracted the tables and pie-charts from the pdf and uploaded as seperate csv files each. After cleaning the csvs, I uploaded those to a folder named data in my project folder. I organised the csv files inside the data folder hierarchically in diffrent branch folders.
   Then, I made the database, importing all the csv files to the database. I implemented the other files as well in the following tree structure depicted by ascii:

                  ├── project
                  │   ├── static
                  │   │   ├── favicon.ico
                  │   │   ├── css
                  │   │   └── js
                  │   ├── data(contains the csv files as backup)
                  │   ├── templates
                  │   │   ├── area_summary.html
                  │   │   ├── crop_analysis.html
                  │   │   ├── crop_yield_info.html
                  │   │   ├── data.html
                  │   │   ├── index.html
                  │   │   ├── pie_chart.html
                  │   │   ├── top_crop_district.html
                  │   │   └── yield_summary.html
                  ├── app.py
                  ├── database.db
                  ├── README.md
                  └── requirements.txt

   From the data optained from the database, I implemented my project in five distinct sections. The descriptions of each are as follows:
   Area Summary:
      It contains the data of production and area allocated for each crop over several years. User can scroll down to see all the data oro seatch any crop in the search bar located above the table.
   Yield Summary:
      It contains the per acre yield amount of each crop or crop variety. User can jump to any page py selecting page number at the bottom of the table, or search specific crop in the search bar located above the table to get info about the crop.
   Crop Analysis:
      If the user chooses any major cereal and a district, he/she would find all the data of that crop in that district. (I am yet to update the data of crops other than the four major cereals of Bangladesh)
   Top Producers:
      Here the user can find two forms. In the first form, he/she can find the top performing districts for any choosen crop variety production. In the other form, the user can select a district to see which crops are produced most in that district.
   Pie-charts:
      I have implemented the area distribution summary of each crops through pie-charts for better visuals. Hovering over the pie charts, user can see the percentage of area used by the cop variety pie hoverd over.

   Throughout the project, chatgpt, gemini, grok, and claude were my partners. The AIs helped me solve a lot of problems. I encountered internal server errors a lot of time. Gemini was a savior.
   In some cases, the errors were called because the null cases of the database were not handled, or with the indentation of loops. Though mostly those were easy solves, the AIs saved a lot of my debugging time.

   The part I struggled with in the project was the extraction of the tables from the pdf. I had to first convert them in csv structure. I had to convert them all into csv files in text editor, and give them unique name as well. It was very repetative, yet something I could not take help from AI. Otherwise the project was fun, I enjoyed a lot.

   The project is not a random placeholder project. Updating the info for all the crops would give the project a good standard that will be suitable for public use as well. I strongly believe that I can reach there someday. The website can be used to analyse which crop would be of best fit for any user for production in his locality. The webapp is dedicated for farmers and other related stakeholders. It provides easy to grash, better visuals to users. It can be a great tool for agricultural decision-making.

   The project is essentially small. However, it has immense scope. With the comprehensive data, a ai model ca be trained that can suggest which crop would be best for production in any particular region and in any particular cropping season. To make it more user friendly and to make it more accessible to its target user, farmars, I will implement this webapp in Bangla as well.

   It was a great experience with a project. I will complete the full project as soon as I manage time.



