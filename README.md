# betting_management
Script to analyze pinnacle betting slips for NFL, NBA, MLB and "other categories"

How to use: 

- Download Pinnacle - Bet History tab
- Odds can be in either decimal or american
- Select all of the data on each of the "slips"
- There should be "16 rows" for each slip when you paste the data into a text file

column_names <- c("Settled_Date", "Prop_Name", "Bet_Details", "Odds",
                      "Bet_No_Label", "Bet_No", "Status", "Accepted_Label", "Accepted_Date",
                      "Stake_Label", "Stake", "Win_Label", "Win", "Payout_Label", "Payout")

- Save betting slips to a file called "pinnacle_slips.txt"
- Open text file in notepad++ or something similar
- Replace all mentions of the below character strings
  - Remove by replacing at symbol with a space after it with nothing
  - Remove comma by replacing comma with nothing

"@ "
","

- Change folder paths to local folders lines #186 and #401
  folder_path <- "C:/Users/willa/Documents/betting/betting management/archive/csv/"
- Run script
- Spits out csv file to enter into "bet tracker"


Sample Input of two betting slips: Note that I removed the @  and , 
---------------------------------------------
Settled:
Sep 29 2024 9:18 PM
Buffalo Bills vs Baltimore Ravens
Baltimore Ravens -2.5
-111
Bet no.
#2012184108
Settled – Win
Accepted:
Sep 28 2024 10:53 PM
Stake:
250.00
Win:
225.23
Payout:
475.23
Settled:
Sep 29 2024 9:18 PM
Buffalo Bills vs Baltimore Ravens
Baltimore Ravens
-140
Bet no.
#2012189475
Settled – Win
Accepted:
Sep 28 2024 11:26 PM
Stake:
250.00
Win:
178.57
Payout:
428.57
------------------------------------------
