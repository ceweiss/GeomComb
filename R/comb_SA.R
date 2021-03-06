#' @title Simple Average Forecast Combination
#'
#' @description Computes forecast combination weights using simple average and produces forecasts for the test set, if provided.
#'
#' @details
#' Suppose \eqn{y_t} is the variable of interest, there are \eqn{N} not perfectly collinear predictors,
#' \eqn{\mathbf{f}_t = (f_{1t}, \ldots, f_{Nt})'}{f_t = (f_{1t}, \ldots, f_{Nt})'}. The simple average gives equal weights to all predictors:
#'
#' \deqn{\mathbf{w}^{SA} = \frac{1}{N}}{w = 1/N}
#'
#' The combined forecast is then obtained by:
#'
#' \deqn{\hat{y}_t = {\mathbf{f}_{t}}'\mathbf{w}^{SA}}{\hat{y}_t = (f_t)'w}
#'
#' It is well-documented that simple average is a robust combination method that is hard to beat (e.g., Stock and Watson, 2004; Timmermann, 2006).
#' This is often associated with the importance of parameter estimation error in sophisticated techniques -- a problem that simple averaging avoids.
#' However, simple averaging may not be a suitable combination method when some of the predictors are biased (Palm and Zellner, 1992).
#'
#' @param x An object of class \code{foreccomb}. Contains training set (actual values + matrix of model forecasts) and optionally a test set.
#'
#' @return Returns an object of class \code{foreccomb_res} with the following components:
#' \item{Method}{Returns the used forecast combination method.}
#' \item{Models}{Returns the individual input models that were used for the forecast combinations.}
#' \item{Weights}{Returns the combination weights obtained by applying the combination method to the training set.}
#' \item{Fitted}{Returns the fitted values of the combination method for the training set.}
#' \item{Accuracy_Train}{Returns range of summary measures of the forecast accuracy for the training set.}
#' \item{Forecasts_Test}{Returns forecasts produced by the combination method for the test set. Only returned if input included a forecast matrix for the test set.}
#' \item{Accuracy_Test}{Returns range of summary measures of the forecast accuracy for the test set. Only returned if input included a forecast matrix and a vector of actual values for the test set.}
#' \item{Input_Data}{Returns the data forwarded to the method.}
#'
#' @author Christoph E. Weiss and Gernot R. Roetzer
#'
#' @examples
#' obs <- rnorm(100)
#' preds <- matrix(rnorm(1000, 1), 100, 10)
#' train_o<-obs[1:80]
#' train_p<-preds[1:80,]
#' test_o<-obs[81:100]
#' test_p<-preds[81:100,]
#'
#' data<-foreccomb(train_o, train_p, test_o, test_p)
#' comb_SA(data)
#'
#' @seealso
#' \code{\link{foreccomb}},
#' \code{\link{plot.foreccomb_res}},
#' \code{\link{summary.foreccomb_res}},
#' \code{\link{accuracy}}
#'
#' @references
#' Palm, F. C., and Zellner, A. (1992). To Combine or not to Combine? Issues of Combining Forecasts. \emph{Journal of Forecasting}, \bold{11(8)}, 687--701.
#'
#' Stock, J. H., and Watson, M. W. (2004). Combination Forecasts of Output Growth in a Seven-Country Data Set. \emph{Journal of Forecasting}, \bold{23(6)},
#' 405--430.
#'
#' Timmermann, A. (2006). Forecast Combinations. In: Elliott, G., Granger, C. W. J., and Timmermann, A. (Eds.), \emph{Handbook of Economic Forecasting},
#' \bold{1}, 135--196.
#'
#' @keywords models
#'
#' @import forecast
#'
#' @export
comb_SA <- function(x) {
    if (class(x) != "foreccomb")
        stop("Data must be class 'foreccomb'. See ?foreccomb, to bring data in correct format.", call. = FALSE)
    observed_vector <- x$Actual_Train
    prediction_matrix <- x$Forecasts_Train
    modelnames <- x$modelnames

    weights <- rep(1/ncol(prediction_matrix), ncol(prediction_matrix))
    fitted <- as.vector(prediction_matrix %*% weights)
    accuracy_insample <- accuracy(fitted, observed_vector)

    if (is.null(x$Forecasts_Test) & is.null(x$Actual_Test)) {
      result <- foreccomb_res(method = "Simple Average", modelnames = modelnames, weights = weights, fitted = fitted, accuracy_insample = accuracy_insample,
                              input_data = list(Actual_Train = x$Actual_Train, Forecasts_Train = x$Forecasts_Train))
    }

    if (is.null(x$Forecasts_Test) == FALSE) {
        newpred_matrix <- x$Forecasts_Test
        pred <- as.vector(newpred_matrix %*% weights)
        if (is.null(x$Actual_Test) == TRUE) {
          result <- foreccomb_res(method = "Simple Average", modelnames = modelnames, weights = weights, fitted = fitted, accuracy_insample = accuracy_insample, pred = pred,
                                  input_data = list(Actual_Train = x$Actual_Train, Forecasts_Train = x$Forecasts_Train, Forecasts_Test = x$Forecasts_Test))
        } else {
            newobs_vector <- x$Actual_Test
            accuracy_outsample <- accuracy(pred, newobs_vector)
            result <- foreccomb_res(method = "Simple Average", modelnames = modelnames, weights = weights, fitted = fitted, accuracy_insample = accuracy_insample, pred = pred,
                                    accuracy_outsample = accuracy_outsample, input_data = list(Actual_Train = x$Actual_Train, Forecasts_Train = x$Forecasts_Train, Actual_Test = x$Actual_Test,
                                    Forecasts_Test = x$Forecasts_Test))
        }
    }
    return(result)
}
