'calc' <- function (asreml)
{
    summ <- summary(asreml)
    vc <- summ$varcomp
    DF <- nrow(vc)
    if ("Fixed" %in% levels(vc$constraint))
        DF <- DF - table(vc$constraint)["Fixed"]
    if ("Constrained" %in% levels(vc$constraint))
        DF <- DF - table(vc$constraint)["Constrained"]
    names(DF) <- ""
    logREML <- summ$loglik
    AIC <- -2 * logREML + 2 * DF
    BIC <- -2 * logREML + DF * log(summ$nedf)
    data.frame(DF, AIC, BIC, logREML)
}
