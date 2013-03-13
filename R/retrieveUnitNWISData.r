#' Raw Data Import for Instantaneous USGS NWIS Data
#'
#' Imports data from NWIS web service. This function gets the data from here: \url{http://waterservices.usgs.gov/}
#' A list of parameter codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/pmcodes/}
#' A list of statistic codes can be found here: \url{http://nwis.waterdata.usgs.gov/nwis/help/?read_file=stat&format=table}
#'
#' @param siteNumber string USGS site number.  This is usually an 8 digit number
#' @param ParameterCd string USGS parameter code.  This is usually an 5 digit number.
#' @param StartDate string starting date for data retrieval in the form YYYY-MM-DD.
#' @param EndDate string ending date for data retrieval in the form YYYY-MM-DD.
#' @param interactive logical Option for interactive mode.  If true, there is user interaction for error handling and data checks.
#' @keywords data import USGS web service
#' @return data dataframe with agency, site, dateTime, time zone, value, and code columns
#' @export
#' @examples
#' siteNumber <- '05114000'
#' ParameterCd <- '00060'
#' StartDate <- as.character(Sys.Date())
#' EndDate <- as.character(Sys.Date())
#' # These examples require an internet connection to run
#' rawData <- retrieveUnitNWISData(siteNumber,ParameterCd,StartDate,EndDate,interactive=FALSE)
retrieveUnitNWISData <- function (siteNumber,ParameterCd,StartDate,EndDate,interactive=TRUE){  
  
  url <- constructNWISURL(siteNumber,ParameterCd,StartDate,EndDate,"uv",StatCd)
  tmp <- read.delim(  
    url, 
    header = TRUE, 
    quote="\"", 
    dec=".", 
    sep='\t',
    colClasses=c('character'),
    fill = TRUE, 
    comment.char="#")

  dataType <- tmp[1,]
  data <- tmp[-1,]
  data[,regexpr('d$', dataType) > 0] <- as.POSIXct(strptime(data[,regexpr('d$', dataType) > 0], "%Y-%m-%d %H:%M"))
  
  tempDF <- data[,which(regexpr('n$', dataType) > 0)]
  tempDF <- suppressWarnings(sapply(tempDF, function(x) as.numeric(x)))  
  data[,which(regexpr('n$', dataType) > 0)] <- tempDF
  row.names(data) <- NULL
  
  return (data)
}