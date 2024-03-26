library(reticulate)
library(jsonlite)
use_python("/usr/local/bin/python3")
server <- function(input, output, session) {
  shinyjs::hide(id = "addPanel")
  ####组件部分————————————————————————————————————————
  values <- reactiveValues(
    btnState = list(),
    gridCounter = 0, # 追踪网格生成次数的计数器
    init_assemb = 0,
    init_cont = 0,
    init_run = 0,
    init_Btn = 0
  )
  
  observeEvent(input$assemb_button, {
    #show
    shinyjs::show(id = "addPanel") 

    values$gridCounter <- values$gridCounter + 1 # 每次生成网格时，计数器加一
    nRows <- input$nRows
    nCols <- input$nCols
    
    for(i in 1:(nRows * nCols)) {
      values$btnState[[paste0("cell", i, "_", values$gridCounter)]] <- 1
    }
    # 初始化所有按钮的状态为1，并使用计数器作为ID的一部分
    output$gridLayout <- renderUI({
      div(id = "btn-container",
          style = paste0("display: flex; flex-wrap: wrap; max-width: ", 50 * nCols, "px;"),
          lapply(1:(nRows * nCols), function(i) {
            btnID <- paste0("cell", i, "_", values$gridCounter) # 使用计数器作为ID的一部分
            actionButton(inputId = btnID, label = "1", class = "btn btn-default custom-btn")
          })
      )
    })
  })
  
  observe({
    lapply(names(values$btnState), function(btnID) {
      if (grepl(paste0("_", values$gridCounter), btnID)) { # 确保只为当前批次的按钮添加观察者
        observeEvent(input[[btnID]], {
          currentState <- values$btnState[[btnID]]
          newState <- ifelse(currentState == 0, 1, 0)
          values$btnState[[btnID]] <- newState
           updateActionButton(session, btnID, label = as.character(newState))
        }, ignoreNULL = TRUE, ignoreInit = TRUE)
      }
    })
  })
  

  # 动态显示所有按钮的状态（可选）
  output$btnStates <- renderUI({
    stateStrings <- lapply(names(values$btnState), function(btnID) {
      stateStr <- paste(btnID, ":", values$btnState[[btnID]])
      HTML(stateStr)
    })
    do.call(tagList, stateStrings)
  })
  
  
  #录入数据
  assemb_data<-reactiveValues(
    back_mat = list(row_data = NULL,
                    col_data = NULL,
                    raw_data = NULL)
  )
  
  observeEvent(input$add_button, {
    values$init_assemb <- 1
    nRows <- input$nRows
    nCols <- input$nCols
    Ammont <- input$Ammont
    btnID <- as.integer(values$btnState[grepl(paste0("_", values$gridCounter), names(values$btnState))])
    raw_data <- btnID
    datas <- list(nRows, nCols, raw_data,Ammont)
    assemb_data$mat <- append(assemb_data$mat, list(datas))
    
    #hide
    shinyjs::hide(id = "addPanel")

  })
  
  observeEvent(input$reset_button, {
    # 重置按钮状态和网格生成次数
    values$btnState <- list()
    values$gridCounter <- 0
    
    # 重置录入数据的反应式值
    assemb_data$mat <- list()
  })

  ####容器部分————————————————————————————————————————
  contains <- reactiveValues(
    btnState = list(),
    gridCounter = 0 # 追踪网格生成次数的计数器
  )
  
  observeEvent(input$contains_button, {
    values$init_Btn <- 1
    nRows2 <- input$nRows2
    nCols2 <- input$nCols2
    
    for(i in 1:(nRows2 * nCols2)) {
      contains$btnState[[paste0("cont", i)]] <- 0
    }
    # 初始化所有按钮的状态为0，并使用计数器作为ID的一部分
    output$gridLayout2 <- renderUI({
      div(id = "btn-container",
          style = paste0("display: flex; flex-wrap: wrap; max-width: ", 50 * nCols2, "px;"),
          lapply(1:(nRows2 * nCols2), function(i) {
            btnID <- paste0("cont", i) # 使用计数器作为ID的一部分
            actionButton(inputId = btnID, label = "0", class = "btn btn-default custom-btn")
          })
      )
    })
  })
  
  observe({
    lapply(names(contains$btnState), function(btnID) {
      if (grepl("cont", btnID)) { # 确保只为当前批次的按钮添加观察者
        observeEvent(input[[btnID]], {
          currentState <- contains$btnState[[btnID]]
          newState <- ifelse(currentState == 0, 1, 0)
          contains$btnState[[btnID]] <- newState
          updateActionButton(session, btnID, label = as.character(newState))
        }, ignoreNULL = TRUE, ignoreInit = TRUE)
      }
    })
  })
  

  # 动态显示所有按钮的状态（可选）
  output$btnStates2 <- renderUI({
    stateStrings <- lapply(names(contains$btnState), function(btnID) {
      stateStr <- paste(btnID, ":", contains$btnState[[btnID]])
      HTML(stateStr)
    })
    do.call(tagList, stateStrings)
  })
  
  #录入数据
  cont_data<-reactiveValues(
    cont_mat = list(row_data = NULL,
                    col_data = NULL,
                    raw_data = NULL)
  )
  
  observeEvent(input$add_button2, {
    values$init_cont <- 1
    nRows2 <- input$nRows2
    nCols2 <- input$nCols2
    btnID <- contains$btnState
    raw_data <- as.integer(btnID)
    datas <- list(nRows2, nCols2, raw_data)
    cont_data$mat <- append(contains$mat, datas)
    
  })
  ####————————————————————————————————————————
  observeEvent(input$run_button, {
    values$init_run <- 1
    #加入python
    py$pack_data <- assemb_data$mat
    py$cont_data <- cont_data$mat
	
	# 指定Python脚本路径
    script_path <- "script.py"
    # 运行Python脚本
    source_python(script_path)
    solutionCount <- py$solution_count
    output$solutionCount <- renderText({
      paste("Amount of solutions:", solutionCount)
    })
    runing_time <- py$runing_time
    output$runing_time <- renderText({
      paste("runing_time:", runing_time)
    })
  })
  ####————————————————————————————————————————
  showBtn <- reactive({values$init_Btn == 1})
  
  observe({
    if(showBtn()) {
      shinyjs::show(id = "add_button2")
    } else {
      shinyjs::hide(id = "add_button2")
    }
  })
  
  ####————————————————————————————————————————
  showRunPanel <- reactive({
    values$init_assemb == 1 && values$init_cont == 1
  })
  
  observe({
    if(showRunPanel()) {
      shinyjs::show(id = "runPanel")
    } else {
      shinyjs::hide(id = "runPanel")
    }
  })
  ####————————————————————————————————————————
  observeEvent(input$disp_button, {
    # 加入python
    py$index <- input$index
    # 指定Python脚本路径
    script_path <- "disp.py"
    
    # 运行Python脚本
    source_python(script_path)
    output$plotImage <- renderImage({
      # 检查文件是否存在
      if (!file.exists("plot.png")) {
        return(NULL)
      }
      
      # 返回图像文件的列表，包括图像路径和删除标志
      list(src = "plot.png",
           contentType = "image/png",
           alt = "This is a plot")
    }, deleteFile = FALSE) # 设置deleteFile为FALSE以避免图像被自动删除
  })
  ####————————————————————————————————————————
  disp_observe <- reactive({
    values$init_run == 1
  })
  observe({
    if(disp_observe()) {
      shinyjs::show(id = "dispPanel")
    } else {
      shinyjs::hide(id = "dispPanel")
    }
  })
  ####————————————————————————————————————————
}
