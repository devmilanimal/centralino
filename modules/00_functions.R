
increment_id <- function(input_id) {
    # Define the prefix manually or extract dynamically
    prefix <- sub("([A-Z]+).*", "\\1", input_id)
    
    # Extract the numeric part
    numeric_part <- gsub("[^0-9]", "", input_id)
    
    # Convert to integer and increment
    numeric_value <- as.integer(numeric_part) + 1
    
    # Reconstruct the ID with the same number of leading zeros
    new_id <- sprintf("%s%05d", prefix, numeric_value)
    
    return(new_id)
}


calculate_age <- function(dob) {
    dob <- as.Date(dob)  # Parses dates in "YearMonthDay" format, adjust with dmy(), mdy(), etc., as needed
    current_date <- Sys.Date()
    age <- as.numeric(difftime(current_date, dob, units = "days")) / 365.25
    age <- floor(age)
    return(age)
}

calculate_expiry_date <- function(pass_type, start_date = Sys.Date()) {
    # Convert the start date to a Date object if it's not already
    start_date <- as.Date(start_date)
    
    # Calculate the expiry date based on the type of pass
    if (pass_type == "Monthly") {
        expiry_date <- start_date %m+% months(1)
    } else if (pass_type == "Quarter") {
        expiry_date <- start_date %m+% months(3)
    } else if (pass_type == "Semester") {
        expiry_date <- start_date %m+% months(6)
    } else if (pass_type == "Yearly") {
        expiry_date <- start_date %m+% months(12)
    } else {
        expiry_date <- start_date + 1
    }
    
    return(expiry_date)
}
