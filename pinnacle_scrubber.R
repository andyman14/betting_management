# Function to process betting slips from a CSV file
process_betting_slips1 <- function(file_path) {

    # Read in the raw data (each field will be in separate rows)
    raw_data <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

    # The number of fields per slip (from your description) is 16
    slip_length <- 16

    # Create an empty dataframe with appropriate column names
    # These are just sample column names, update based on actual fields
    column_names <- c("Date_Settled", "Bet_Description", "Bet_Details", "Odds",
                      "Bet_No", "Status", "Date_Accepted", "Stake",
                      "Win", "Payout", "Additional_Field_1", "Additional_Field_2",
                      "Additional_Field_3", "Additional_Field_4", "Additional_Field_5", "Additional_Field_6")

    # Initialize an empty dataframe with the column names
    slips_df <- data.frame(matrix(ncol = length(column_names), nrow = 0))
    colnames(slips_df) <- column_names

    # Loop over the data, process each slip (group of 16 rows)
    for (i in seq(1, nrow(raw_data), by = slip_length)) {

        # Extract the 16 lines corresponding to one slip
        slip <- raw_data[i:(i + slip_length - 1), 1]

        # Add this slip as a new row in the dataframe
        slips_df <- rbind(slips_df, t(slip))
    }

    # Return the processed dataframe
    return(slips_df)
}

# Optimized Function to process betting slips and ensure full payout value is captured
process_betting_slips_optimized <- function(file_path) {

    # Read in the raw data (each field will be in separate rows)
    raw_data <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

    # The number of fields per slip is 16
    slip_length <- 16

    # Define column names based on your actual data structure
    column_names <- c("Settled_Date", "Prop_Name", "Bet_Details", "Odds",
                      "Bet_No_Label", "Bet_No", "Status", "Accepted_Label", "Accepted_Date",
                      "Stake_Label", "Stake", "Win_Label", "Win", "Payout_Label", "Payout")

    # Initialize an empty list to store rows (better performance than appending rows to data frames)
    slip_list <- list()

    # Loop over the data, process each slip (group of 16 rows)
    for (i in seq(1, nrow(raw_data), by = slip_length)) {

        # Extract the 16 lines corresponding to one slip
        slip <- raw_data[i:(i + slip_length - 1), 1]

        # Ensure that the slip starts with "Settled" and not "Live Settled"
        if (grepl("^Settled", slip[1])) {

            # Apply trimws() to remove leading/trailing whitespace from all fields
            slip <- trimws(slip)

            # Remove any occurrence of the word "Live" and its surrounding spaces from the slip
            slip <- gsub("\\s*Live\\s*", "", slip)  # This will remove "Live" and any extra spaces around it

            # Remove "@" from the odds, ensuring no spaces are left behind
            odds <- gsub("\\s*@\\s*", "", slip[4])  # This will remove both "@" and any spaces around it

            # Create a cleaned-up slip as a vector for adding to the list
            cleaned_slip <- c(slip[1], slip[2], slip[3], odds, slip[5], slip[6],
                              slip[7], slip[8], slip[9], slip[10], slip[11], slip[12], slip[13], slip[14], slip[15])

            # Append the cleaned slip as a row to the list
            slip_list <- append(slip_list, list(cleaned_slip))
        }
    }

    # Convert the list of slips into a dataframe and assign column names
    slips_df <- do.call(rbind, slip_list)
    slips_df <- as.data.frame(slips_df, stringsAsFactors = FALSE)
    colnames(slips_df) <- column_names

    # Return the cleaned dataframe with proper column names
    return(slips_df)
}

#--------------------------------------------------

mlb_team_names <- c("Arizona Diamondbacks", "Atlanta Braves", "Baltimore Orioles", "Boston Red Sox",
                    "Chicago Cubs", "Chicago White Sox", "Cincinnati Reds", "Cleveland Guardians",
                    "Colorado Rockies", "Detroit Tigers", "Houston Astros", "Kansas City Royals",
                    "Los Angeles Angels", "Los Angeles Dodgers", "Miami Marlins", "Milwaukee Brewers",
                    "Minnesota Twins", "New York Mets", "New York Yankees", "Oakland Athletics",
                    "Philadelphia Phillies", "Pittsburgh Pirates", "San Diego Padres", "San Francisco Giants",
                    "Seattle Mariners", "St. Louis Cardinals", "Tampa Bay Rays", "Texas Rangers",
                    "Toronto Blue Jays", "Washington Nationals")

# List of NFL teams
nfl_team_names <- c("Arizona Cardinals", "Atlanta Falcons", "Baltimore Ravens", "Buffalo Bills",
                    "Carolina Panthers", "Chicago Bears", "Cincinnati Bengals", "Cleveland Browns",
                    "Dallas Cowboys", "Denver Broncos", "Detroit Lions", "Green Bay Packers",
                    "Houston Texans", "Indianapolis Colts", "Jacksonville Jaguars", "Kansas City Chiefs",
                    "Las Vegas Raiders", "Los Angeles Chargers", "Los Angeles Rams", "Miami Dolphins",
                    "Minnesota Vikings", "New England Patriots", "New Orleans Saints", "New York Giants",
                    "New York Jets", "Philadelphia Eagles", "Pittsburgh Steelers", "San Francisco 49ers",
                    "Seattle Seahawks", "Tampa Bay Buccaneers", "Tennessee Titans", "Washington Commanders")

# List of NBA teams
nba_team_names <- c("Atlanta Hawks", "Boston Celtics", "Brooklyn Nets", "Charlotte Hornets",
                    "Chicago Bulls", "Cleveland Cavaliers", "Dallas Mavericks", "Denver Nuggets",
                    "Detroit Pistons", "Golden State Warriors", "Houston Rockets", "Indiana Pacers",
                    "Los Angeles Clippers", "Los Angeles Lakers", "Memphis Grizzlies", "Miami Heat",
                    "Milwaukee Bucks", "Minnesota Timberwolves", "New Orleans Pelicans", "New York Knicks",
                    "Oklahoma City Thunder", "Orlando Magic", "Philadelphia 76ers", "Phoenix Suns",
                    "Portland Trail Blazers", "Sacramento Kings", "San Antonio Spurs", "Toronto Raptors",
                    "Utah Jazz", "Washington Wizards")


#--------------------------------------------------
# Load raw slips into a dataframe and apply formatting
process_betting_slips_raw <- function(file_path) {

    # Read in the raw data (each field will be in separate rows)
    raw_data <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

    # Step 1: Remove any rows with "Live" in the raw data
    raw_data <- raw_data %>%
        filter(!str_detect(V1, "Live"))

    # The number of fields per slip is 16
    slip_length <- 16

    # Generate generic column names (e.g., column_1, column_2, ..., column_16)
    column_names <- paste0("column_", 1:slip_length)

    # Initialize an empty list to store rows (better performance than appending rows to data frames)
    slip_list <- list()

    # Step 2: Loop over the data, process each slip (group of 16 rows)
    for (i in seq(1, nrow(raw_data), by = slip_length)) {

        # Check if we have at least 16 rows left to process
        if ((i + slip_length - 1) <= nrow(raw_data)) {

            # Extract the 16 lines corresponding to one slip
            slip <- raw_data[i:(i + slip_length - 1), 1]

            # Apply trimws() to remove leading/trailing whitespace from all fields
            slip <- trimws(slip)

            # Remove the '@ ' from odds (typically in positions like column_14)
            slip[which(str_detect(slip, "^@"))] <- str_replace(slip[which(str_detect(slip, "^@"))], "^@\\s+", "")

            # Append the slip as a row to the list
            slip_list <- append(slip_list, list(slip))
        }
    }

    # Step 3: Convert the list of slips into a dataframe only if the list has content
    if (length(slip_list) > 0) {
        slips_df <- do.call(rbind, slip_list)
        slips_df <- as.data.frame(slips_df, stringsAsFactors = FALSE)
        colnames(slips_df) <- column_names
    } else {
        # Return an empty dataframe with column names if no slips were processed
        slips_df <- data.frame(matrix(ncol = slip_length, nrow = 0))
        colnames(slips_df) <- column_names
    }

    # Step 4: Now, remove commas only from the numeric fields (e.g., stake, win, payout in columns 4, 6, and 8)
    numeric_columns <- c("column_4", "column_6", "column_8")  # Example columns for stake, win, and payout

    slips_df <- slips_df %>%
        mutate(across(all_of(numeric_columns), ~ str_replace_all(., ",", "")))  # Remove commas from these fields

    # Step 5: Apply final trimming and formatting across all columns to remove whitespaces
    slips_df <- slips_df %>%
        mutate(across(everything(), ~ str_trim(.)))  # Trim whitespaces from all columns

    # Return the formatted raw dataframe with generic column names
    return(slips_df)
}

# Define the folder path containing your files
folder_path <- "C:/Users/willa/Documents/betting/betting management/archive/input/"  # Update the path as needed

# For example, if you know the filenames have a certain pattern (e.g., "pinnacle_slips_*"), you can filter with `pattern`
# file_list <- list.files(path = folder_path, pattern = "pinnacle_slips_.*\\.csv", full.names = TRUE)
file_list <- list.files(path = folder_path, pattern = "pinnacle_props_2024.csv", full.names = TRUE)

# Initialize an empty list to store dataframes from each file
slips_list <- list()

# Loop over each file and process it
for (file_path in file_list) {
    # Process the betting slips from each file
    raw_slips <- process_betting_slips_raw(file_path)
    # Convert to a tibble for easier viewing/manipulation
    processed_slips <- tibble(raw_slips)
    # Append the processed slips to the list
    slips_list <- append(slips_list, list(processed_slips))
}

# Optionally, you can combine all the individual dataframes into one
raw_slips <- bind_rows(slips_list)
view(raw_slips)

#--------------------------------------------------

# Create function to process raw_slips
# Process raw slips into usable DF
clean_betting_slips <- function(df) {

    # Step 1: Remove redundant columns and select relevant ones
    cleaned_df <- df %>%
        select(
            column_10,  # Accepted date
            column_12,  # Stake amount
            column_14,  # Win amount
            column_16,  # Payout amount
            column_2, # Settled date
            column_7, # Bet number
            column_3, # Bet description
            column_4,  # Bet details
            column_5, # Odds
            column_8, # Status
        )

    # Step 3: Rename the remaining columns to more meaningful names
    cleaned_df <- cleaned_df %>%
        rename(
            accepted_date = column_10,
            stake = column_12,
            win = column_14,
            payout = column_16,
            settled_date = column_2,
            bet_description = column_3,
            bet_details = column_4,
            odds = column_5,
            result = column_8
        )

    # Ensure odds are numeric
    cleaned_df <- cleaned_df %>%
        mutate(odds = as.numeric(odds))  # Convert odds to numeric

    # Convert odds to decimal
    cleaned_df <- cleaned_df %>%
        mutate(decimal_odds = ifelse(
            odds > 0,
            round(1 + (odds / 100), 3),    # Convert positive American odds
            round(1 + (100 / abs(odds)), 3)  # Convert negative American odds
        ))

    # Rearrange final columns
    cleaned_df <- cleaned_df %>%
        select(accepted_date, settled_date, stake, win, payout, decimal_odds, bet_description, bet_details, result)

    # Return the cleaned dataframe
    return(cleaned_df)
}

# Convert from American odds to decimal
# Example usage:
processed_slips <- clean_betting_slips(raw_slips)
tibble(processed_slips)
view(processed_slips)

# Modify the tibble with new columns
processed_slips <- processed_slips %>%
    # Create a new date column by extracting the date part from settled_date
    mutate(
        date = mdy(str_extract(settled_date, "\\w+ \\d{1,2} \\d{4}")),

        # Create a new column that maps result to 1 for Win and 0 for Loss
        result_binary = ifelse(str_detect(result, "Win"), 1, 0)
    )
# View the updated tibble
processed_slips <- processed_slips %>%
    select(date, stake, win, payout, decimal_odds, result_binary, bet_description, bet_details)
#--------------------------------------------------

# Filter processed_slips for MLB bet entry
# Function to filter processed_slips by MLB team names
filter_mlb_bets <- function(df, mlb_teams) {

    # Use dplyr to filter the dataframe
    filtered_df <- df %>%
        filter(str_detect(bet_description, paste(mlb_teams, collapse = "|")))

    # Return the filtered dataframe
    return(filtered_df)
}
# Example usage
processed_slips_mlb <- filter_mlb_bets(processed_slips, mlb_team_names)
tibble(processed_slips_mlb)
view(processed_slips_mlb)
#--------------------------------------------------

# Format for everything other than MLB, NFL, NBA
# Function to filter processed_slips for non-MLB bets
filter_bets_other <- function(df, mlb_teams, nfl_teams, nba_teams) {

    # Use dplyr to filter the dataframe for entries that do not match MLB, NFL, or NBA teams
    filtered_df <- df %>%
        filter(!stringr::str_detect(bet_description, paste(mlb_teams, collapse = "|"))) %>%
        filter(!stringr::str_detect(bet_description, paste(nfl_teams, collapse = "|"))) %>%
        filter(!stringr::str_detect(bet_description, paste(nba_teams, collapse = "|")))

    # Return the filtered dataframe
    return(filtered_df)
}

# Example usage with MLB, NFL, and NBA team lists
processed_slips_other <- filter_bets_other(processed_slips, mlb_team_names, nfl_team_names, nba_team_names)

# View the filtered dataframe for non-MLB bets
tibble(processed_slips_other)
view(processed_slips_other)
#--------------------------------------------------

# Format for NFL teams

# Function to filter processed_slips for non-NFL bets
filter_nfl_bets <- function(df, nfl_teams) {

    # Use dplyr to filter the dataframe for entries that do not match NFL teams
    filtered_df <- df %>%
        filter(stringr::str_detect(bet_description, paste(nfl_teams, collapse = "|")))

    # Return the filtered dataframe
    return(filtered_df)
}

# Example usage for NFL filtering
processed_slips_nfl <- filter_nfl_bets(processed_slips, nfl_team_names)
# View the filtered dataframe for non-MLB bets
tibble(processed_slips_nfl)
view(processed_slips_nfl)

#--------------------------------------------------

# Format for NBA teams
# Function to filter processed_slips for non-NBA bets
filter_nba_bets <- function(df, nba_teams) {

    # Use dplyr to filter the dataframe for entries that do not match NBA teams
    filtered_df <- df %>%
        filter(stringr::str_detect(bet_description, paste(nba_teams, collapse = "|")))

    # Return the filtered dataframe
    return(filtered_df)
}

# Example usage for NBA filtering
processed_slips_nba <- filter_nba_bets(processed_slips, nba_team_names)
# View the filtered dataframe for non-MLB bets
tibble(processed_slips_nba)
view(processed_slips_nba)

#--------------------------------------------------
# Format for NFL Props
# Function to filter processed_slips for NFL prop bets
filter_nfl_props <- function(df, nfl_props) {

    # Use dplyr to filter the dataframe for entries that match NFL prop categories
    filtered_df <- df %>%
        filter(stringr::str_detect(bet_description, paste(nfl_props, collapse = "|")))

    # Return the filtered dataframe
    return(filtered_df)
}

  # List of NFL prop categories
  nfl_prop_categories <- c("Receptions", "Receiving Yards", "Completions",
                         "TD Passes", "Rushing Yards", "Interceptions",
                         "1st TD Scorer", "Anytime TD", "Pass Attempts")

# Example usage for NFL prop filtering
processed_slips_props <- filter_nfl_props(processed_slips, nfl_prop_categories)
# View the filtered dataframe for non-MLB bets
tibble(processed_slips_props)
view(processed_slips_props)

#--------------------------------------------------

nrow(raw_slips)
nrow(processed_slips)
nrow(processed_slips_mlb)
nrow(processed_slips_nba)
nrow(processed_slips_nfl)
nrow(processed_slips_other)
nrow(processed_slips_props)
#--------------------------------------------------


# Define the file path with timestamp
today_date <- format(Sys.Date(), "%Y-%m-%d")  # Formats today's date as 'YYYY-MM-DD'
current_time <- format(Sys.time(), "%H-%M-%S")  # Formats the current time as 'HH-MM-SS'
folder_path <- "C:/Users/willa/Documents/betting/betting management/archive/csv/"  # Update the path as needed
filename <- paste0("processed_slips_nfl_props_", today_date, "_", current_time, ".csv")  # Create filename with today's date and time
full_path <- file.path(folder_path, filename)  # Combine folder path and filename
# Write the dataframe to a CSV file
write.csv(processed_slips_props, full_path, row.names = FALSE)
# Print a message to confirm
cat("CSV file has been saved at", full_path, "\n")
