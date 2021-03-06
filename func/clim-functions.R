## convenience functions
CtoF <- function(x) { 1.8*x + 32 }
FtoC <- function(x) { (x - 32) / 1.8 }
KtoC <- function(x) { (x - 273.15) }
CtoK <- function(x) { (x + 273.15) }

is.okay <- function(x) {
    !(is.infinite(x) + is.na(x) + is.nan(x))
}


## efficient functions

aggindex <- function(indexdat) {
	newinfo <- lapply(data.frame(indexdat, stringsAsFactors=FALSE), function(x)sort(unique(x)))
	expand.grid(newinfo, stringsAsFactors=FALSE)
}


aggfun <- function(dat, indexdat, FUN, ...) {
	if(!is.null(dim(dat))) {
		result <- apply(dat, 2, function(x)tapply(x, indexdat, FUN=FUN, na.rm=TRUE, ...))
	} else {
		dat <- split(dat, indexdat)
		result <- sapply(dat, FUN, na.rm=TRUE)
	}
	result
}



####


fastmean <- function(x) {
    x <- x[!is.na(x)]
    sum(x)/length(x)
}



fastskew <- function(x) {
    x <- x[!is.na(x)]
    n <- length(x)
    x <- x - sum(x)/length(x)
    y <- sqrt(n) * sum(x^3)/(sum(x^2)^(3/2))
    y * ((1 - 1/n))^(3/2)
}


fastsd <- function(x) {
    xvar <- .Call(stats:::C_cov, x, NULL, 5, FALSE, PACKAGE="stats")
    sqrt(xvar)
}


# efficient write to file

fappend <- function(output, outfile, outnames) {
    if(is.vector(output)) {
        output <- data.frame(matrix(output, nrow=1))
        colnames(output) <- outnames
    }
    if(file.exists(outfile)) {
        fwrite(output, outfile, append=TRUE, col.names=FALSE, sep=",", na="NA")
    } else {
        fwrite(output, outfile, append=FALSE, col.names=TRUE, sep=",", na="NA")
    }
    invisible()
}

#

##### keepthese

climstat <- function(x, xsub) {
    if(!missing(xsub)) {
        x <- x[xsub]
    }
    z <- try(zyp::zyp.trend.vector(x), silent=TRUE)
    if(inherits(z, "try-error")) 
        z <- c(lbound = NA_real_, trend = NA_real_, trendp = NA_real_, ubound = NA_real_, 
tau = NA_real_, sig = NA_real_, nruns = NA_real_, autocor = NA_real_, 
valid_frac = NA_real_, linear = NA_real_, intercept = NA_real_
)

    c(mean=mean(x, na.rm=TRUE), 
      quantile(x, probs=c(.1, .5, .9), na.rm=TRUE), 
      NAs=sum(is.na(x)), z)
}

#


climchunk <- function(x, inc=5, span=30) {
    # takes a data frame; calculates sequential quantiles
	n <- nrow(x)
	seqs <- data.frame(start=seq(1, n-span+1, by=inc), end=seq(span, n, by=inc))
    result <- vector(nrow(seqs), mode="list")
	for(i in seq_len(nrow(seqs))) {
		result[[i]] <- apply(x, 2, climstat, xsub = seq(seqs$start[i], seqs$end[i]))
		names(result)[i] <- paste0("q", rownames(x)[seqs$start[i]])
	}

    # add overall summary
    result[["all"]] <- apply(x, 2, climstat)


	result
}

#


speiall <- function(x, lat, ref.start=c(1981, 1), ref.end=c(2010, 12), monthcol="month", yearcol="year", tmeancol="tmean", precipcol="precip") {

    pr <- x[[precipcol]]
    tave <- x[[tmeancol]]

    startyear <- as.numeric(x[[yearcol]][1])
    startmonth <- as.numeric(x[[monthcol]][1])

    thistw <- thornthwaite(tave, lat)

    spei01tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale= 1, ref.start=ref.start, ref.end=ref.end)
    spei03tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale= 3, ref.start=ref.start, ref.end=ref.end)
    spei06tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale= 6, ref.start=ref.start, ref.end=ref.end)
    spei09tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale= 9, ref.start=ref.start, ref.end=ref.end)
    spei12tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale=12, ref.start=ref.start, ref.end=ref.end)
    spei18tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale=18, ref.start=ref.start, ref.end=ref.end)
    spei24tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale=24, ref.start=ref.start, ref.end=ref.end)
    spei36tw <- spei(ts(pr - thistw, freq=12, start=c(startyear, startmonth)), scale=36, ref.start=ref.start, ref.end=ref.end)

    list(thornthwaite = thistw, 
        spei01tw = spei01tw,
        spei03tw = spei03tw,
        spei06tw = spei06tw,
        spei09tw = spei09tw,
        spei12tw = spei12tw, 
        spei18tw = spei18tw, 
        spei24tw = spei24tw, 
        spei36tw = spei36tw)

}


