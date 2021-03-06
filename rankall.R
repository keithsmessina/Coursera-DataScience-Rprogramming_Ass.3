rankall <- function(outcome, num = "best") {

  
  ## Create a vector with all of the valid outcomes options
  outcome.vector <- c("heart attack", "heart failure", "pneumonia")
  
  ## Check if input outcome value exists as a valid outcome option
  if(!(outcome %in% outcome.vector))stop("invalid outcome") 
  
  ## Read outcome data
  care.data <- read.csv("outcome-of-care-measures.csv")
  
  care.data.states <- unique(care.data[,7])
  care.data.states <- as.vector(care.data.states)
  
  state.rank.list <- data.frame(matrix(ncol=2,nrow=length(care.data.states)))
  colnames(state.rank.list) <- c("hospital","state")

  state.row.names <- c(1:length(care.data.states))
  
  for(state.index in 1:length(care.data.states)){
    state <- care.data.states[state.index]
    ## Check that state is valid
    if(!(state %in% care.data$State))stop("invalid state")

    ## Return hospital name in that state with the given rank
    ## 30-day death rate
    
    ## Convert the outcome input into the function into the 
    ## data frame column number that matches the desired outcome
    if(outcome == "heart attack") {
      outcome.match <- 11
    } else if(outcome == "heart failure") {
      outcome.match <- 17
    } else {
      outcome.match <- 23
    }
    
    ## Save a subset of the data frame, saving just the relevant
    ## columns (Hospital Name, Outcome) with the state matching the
    ## input state
    care.data.filtered <- care.data[care.data$State==state,c(2,outcome.match)]
    
    ## CHange the outcome data into a numeric so it can be sorted
    care.data.filtered[,2] <- suppressWarnings(as.numeric(as.character(care.data.filtered[,2])))
    care.data.filtered[,1] <- suppressWarnings(as.character(care.data.filtered[,1]))
    ## Remove NAs from the data frame
    care.data.filtered <- care.data.filtered[!is.na(care.data.filtered[,2]),]
    
    ## Sort the dataframe by the outcome column
    care.data.filtered <- care.data.filtered[order(care.data.filtered[,2]),]
    
    tied <- match(care.data.filtered[,2],care.data.filtered[,2])
    duplicate.mask <- duplicated(care.data.filtered[,2])
    tied.vector <- unique(tied[duplicate.mask])
    for(i in 1:length(tied.vector)) {
      duplicate.index <- which(tied %in% tied.vector[i])
      sort.fragment <- care.data.filtered$Hospital.Name[duplicate.index]
      sort.fragment <- sort.fragment[order(sort.fragment)]
      care.data.filtered$Hospital.Name[duplicate.index] <- sort.fragment
    }
    if(num %in% "worst"){
      num.state <- length(care.data.filtered$Hospital.Name)
    } else if(num %in% "best"){
      num.state <- 1
    } else {
      num.state <- num
    }
    state.rank.list$state[state.index] <- state
    state.rank.list$hospital[state.index] <- care.data.filtered$Hospital.Name[num.state]
    state.row.names[state.index] <- state
  }
  row.names(state.rank.list) <- state.row.names
  state.rank.list <- state.rank.list[order(as.character(state.rank.list$state)),]
  return(state.rank.list)
}