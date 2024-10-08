#' Create a Shiny Tree
#' 
#' This creates a spot in your Shiny UI for a shinyTree which can then be filled
#' in using \code{\link{renderTree}}.
#' 
#' A shinyTree is an output *and* an input element in the same time. While you can 
#' fill it via \code{\link{renderTree}} you can access its content via \code{input$tree} 
#' (for example after the user rearranged some nodes). By default, \code{input$tree} will
#' return a list similiar to the one you use to fill the tree. This behaviour is controlled
#' by \code{getOption("shinyTree.defaultParser")}. It defaults to \code{"list"}, but can be set 
#' to \code{"tree"}, in which case a \code{\link[data.tree]{data.tree}} is returned.
#' 
#' @param outputId The ID associated with this element
#' @param checkbox If \code{TRUE}, will enable checkboxes next to each node to 
#' make the selection of multiple nodes in the tree easier.
#' @param searchplaceholder Add a placeholder value to the search box
#' @param search If \code{TRUE}, will enable search functionality in the tree by adding
#' a search box above the produced tree. Alternatively, you can set the parameter
#' to the ID of the text input you wish to use as the search field.
#' @param searchtime Determines the reaction time of the search algorithm.
#' Default is 250ms.
#' @param dragAndDrop If \code{TRUE}, will allow the user to rearrange the nodes in the
#' tree.
#' @param types enables jstree types functionality when sent proper json (please see the types example)
#' @param theme jsTree theme, one of \code{default}, \code{default-dark}, or \code{proton}.
#' @param themeIcons If \code{TRUE}, will show theme icons for each item.
#' @param themeDots If \code{TRUE}, will include level dots.
#' @param sort If \code{TRUE}, will sort the nodes in alphabetical/numerical
#' order.
#' @param unique If \code{TRUE}, will ensure that no node name exists more
#' than once.
#' @param wholerow If \code{TRUE}, will highlight the whole selected row.
#' @param stripes If \code{TRUE}, the tree background is striped.
#' @param multiple If \code{TRUE}, multiple nodes can be selected.
#' @param three_state If \code{TRUE}, a boolean indicating if checkboxes should cascade down and have an undetermined state
#' @param whole_node If \code{TRUE},a boolean indicating if clicking anywhere on the node should act as clicking on the checkbox
#' @param tie_selection If \code{TRUE}, controls if checkbox are bound to the general tree selection or to an internal array maintained by the checkbox plugin.
#' @param animation The open / close animation duration in milliseconds.
#' Set this to \code{FALSE} to disable the animation (default is 200).
#' @param contextmenu If \code{TRUE}, will enable a contextmenu to 
#' create/rename/delete/cut/copy/paste nodes.
#' @seealso \code{\link{renderTree}}
#' @export
shinyTree <- function(outputId, checkbox=FALSE, search=FALSE, 
                      searchtime = 250, searchplaceholder = "", dragAndDrop=FALSE, types=NULL, 
                      theme="default", themeIcons=TRUE, themeDots=TRUE,
                      sort=FALSE, unique=FALSE, wholerow=FALSE,
                      stripes=FALSE, multiple=TRUE, animation=200,
                      contextmenu=FALSE, three_state=TRUE, whole_node=TRUE, tie_selection=TRUE){
  
  if ((!is.null(contextmenu) && contextmenu) && (!is.null(checkbox) && checkbox)) {
    warning("The plugins contextmenu and checkbox cannot be used together. \nSet checkbox to FALSE")
    checkbox = FALSE
  }
  
  searchEl <- shiny::div("")
  if (search == TRUE){
    search <- paste0(outputId, "-search-input")
    searchEl <- shiny::tags$input(id=search, class="input", type="text", value="", placeholder = searchplaceholder)
  }
  if (is.character(search)){
    # Either the search field we just created or the given text field ID
    searchEl <- shiny::tagAppendChild(searchEl, shiny::tags$script(type="text/javascript", shiny::HTML(
      paste0("shinyTree.initSearch('",outputId,"','",search,"', ", searchtime,");"))))
  }
  
  if(!theme %in% c("default","default-dark","proton")) { stop(paste("shinyTree theme, ",theme,", doesn't exist!",sep="")) }
  
  # define theme tags (default, default-dark, or proton)
  theme.tags<-shiny::tags$link(rel = 'stylesheet',
                               type = 'text/css',
                               href = paste('shinyTree/jsTree-3.3.7/themes/',theme,'/style.min.css',sep=""))
  
  opts <- jsonlite::toJSON(list(
    'setState' = getOption('shinyTree.setState'),
    'refresh' = getOption('shinyTree.refresh')
    ), auto_unbox = T)
  
  if(!animation){
    animation = 'false'
  }
  if(!is.null(types)){
    outputnohyp <- gsub("-","_",outputId, fixed=T)
    types <- paste0(outputnohyp,"_sttypes = ",types)
  }
  shiny::tagList(
    shiny::singleton(shiny::tags$head(
      initResourcePaths(),
      theme.tags,
      shiny::tags$link(rel = "stylesheet", 
                type = "text/css", 
                href="https://use.fontawesome.com/releases/v5.7.2/css/all.css",
                integrity="sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr",
                crossorigin="anonymous"),
      shiny::tags$script(src = 'shinyTree/jsTree-3.3.7/jstree.min.js'),
      shiny::tags$script(src = 'shinyTree/shinyTree.js'),
      shiny::tags$script(shiny::HTML(types))
    )),
    searchEl,
    shiny::div(id=outputId, class="shiny-tree", 
        `data-st-checkbox`=checkbox, 
        `data-st-tie-selection`=tie_selection,
        `data-st-whole-node`=whole_node,
        `data-st-three-state`=three_state,
        `data-st-search`=is.character(search),
        `data-st-dnd`=dragAndDrop,
        `data-st-types`=!is.null(types),
        `data-st-theme`=theme,
        `data-st-theme-icons`=themeIcons,
        `data-st-theme-dots`=themeDots,
        `data-st-theme-stripes`=stripes,
        `data-st-multiple`=multiple,
        `data-st-animation`=animation,
        `data-st-sort`=sort,
        `data-st-unique`=unique,
        `data-st-wholerow`=wholerow,
        `data-st-contextmenu`=contextmenu,
        options = opts
        )
  )
}
