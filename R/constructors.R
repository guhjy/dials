#' Tools for creating new parameter objects
#' 
#' These functions are used to construct new parameter objects. 
#' 
#' @param type A single character value. For quantitative parameters, valid 
#' choices are "double" and "integer" while for qualitative factors they are 
#' "character" and "logical". 
#' @param range A two-element list of vector with the lowest or largest possible
#'  values, respectively. If these cannot be set when the parameter is defined, 
#'  the `unknown()` function can be used. If a transformation is specified, 
#'  these values should be in the _transformed units_.
#' @param inclusive A two-element logical vector for whether the the range 
#'  values should be inclusive or exclusive. 
#' @param default A single value the same class as `type` for the default 
#' parameter value. `unknown()` can also be used here. 
#' @param trans A `trans` object from the \pkg{scales} package, such as
#'  [scales::log10_trans()] or [scales::reciprocal_trans()]. 
#' @param values A vector of possible values that is required when `type` is
#' "character" or "logical" but optional otherwise.  
#' @param label An optional named character string that can be used for
#' printing and plotting. The named should reflect the object name (e.g. 
#' "mtry", "neighbors", etc.)
#' @param finalize A function that can be used to set the  data-specific 
#'  values of a parameter (such as the range).
#' @return An object of class "param" with the primary class being either 
#' "quant_param" or "qual_param". The `range` element of the object is always 
#' converted to a list with elements "lower" and "upper". '
#' @examples
#' num_subgroups <-
#'   new_quant_param(
#'     type = "integer",
#'     range = c(1L, 20L),
#'     inclusive = c(TRUE, TRUE),
#'     trans = NULL,
#'     label = c(num_subgroups = "# Subgroups"),
#'     finalize = NULL
#'   )
#' @export
#' @importFrom scales is.trans
new_quant_param <- function(
  type = c("double", "integer"), range, inclusive, 
  default = unknown(),
  trans = NULL, values = NULL, label = NULL, finalize = NULL) {
  type <- match.arg(type)
  
  range <- as.list(range)
  
  if (length(inclusive) != 2)
    stop("`inclusive` must have upper and lower values.", all. = FALSE)
  if (any(is.na(inclusive)))
    stop("Boundary descriptors must be non-missing.", call. = FALSE)
  if (!is.logical(inclusive))
    stop("`inclusive` should be logical", call. = FALSE)  
  
  if (!is.null(trans)) {
    if (!is.trans(trans))
      stop(
        "`trans` must be a 'trans' class object (or NULL). See ", 
        "`?scales::trans_new`.", call. = FALSE
      )
  }
  
  check_label(label)
  check_finalize(finalize)
  
  names(range) <- names(inclusive) <- c("lower", "upper")
  res <- list(type = type, range = range, inclusive = inclusive, 
              trans = trans, default = default,
              label = label, finalize = finalize)
  class(res) <- c("quant_param", "param")
  range_validate(res, range)
  
  if (!is.null(values)) {
    ok_vals <- value_validate(res, values)
    if(all(ok_vals))
      res$values <- values
    else 
      stop("Some values are not valid: ",
           glue_collapse(
             values[!ok_vals],
             sep = ", ",
             last = " and ",
             width = min(options()$width - 30, 10)
           ))
  }
  
  res
}

#' @export
#' @rdname new_quant_param
new_qual_param <- function(type = c("character", "logical"), values,
                           default = unknown(), label = NULL, 
                           finalize = NULL) {
  type <- match.arg(type)
  
  if (type == "logical") {
    if (!is.logical(values))
      stop("`values` must be logical", call. = FALSE)
  }
  if (type == "character") {
    if (!is.character(values))
      stop("`values` must be character", call. = FALSE)
  }
  if (is_unknown(default))
    default <- values[1]
  
  check_label(label)
  check_finalize(finalize)
  
  res <- list(type = type, default = default,
              label = label, values = values, 
              finalize = finalize)
  class(res) <- c("qual_param", "param") 

  res
}


###################################################################

#' @export
#' @importFrom purrr map_chr
#' @importFrom glue glue
print.quant_param <- function(x, digits = 3, ...) {
  if (!is.null(x$label)) {
    cat(x$label, " (quantitative)\n")
  } else
    cat("Quantitative Parameter\n")
  if (!is.null(x$trans)) {
    print(eval(x$trans))
    cat("Range (transformed scale): ")
  } else
    cat("Range: ")
  
  vals <- map_chr(x$range, format_range_val)
  bnds <- format_bounds(x$inclusive)
  cat(glue('{bnds[1]}{vals[1]}, {vals[2]}{bnds[2]}\n'))
  invisible(x)
}

#' @export
#' @importFrom glue glue_collapse
print.qual_param <- function(x, ...) {
  if (!is.null(x$label)) {
    cat(x$label, " (qualitative)\n")
  } else
    cat("Qualitative Parameter\n")
  cat(length(x$values), "possible value include:\n")
  if (x$type == "character")
    lvls <- paste0("'", x$values, "'")
  else 
    lvls <- x$values
  cat(
    glue_collapse(
      lvls,
      sep = ", ",
      last = " and ",
      width = options()$width
    ),
    "\n")
  invisible(x)
}




