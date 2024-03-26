library(shinyjs)
library(shiny)

ui <- fluidPage(
  titlePanel("求解装箱"),
  useShinyjs(),
  hidden(div(textInput("uniqueID", NULL, value = ""))),
  tags$head(
    tags$style(HTML("
    .custom-btn {
      width: 50px; /* 设置按钮宽度为50px */
      height: 50px; /* 设置按钮高度为50px */
      margin-right: 0px; /* 设置按钮右边间隔为0px */
      margin-bottom: 0px; /* 设置按钮底部间隔为0px */
    }
    /* 容器样式，用于确保最后一个按钮的右间隔 */
    .btn-container {
      display: flex;
      flex-wrap: wrap;
      align-items: flex-start;
      justify-content: flex-start;
    }
    .btn-default { background-color: #FFFFFF; color: black; }
    .btn-active { background-color: #007bff; color: black; }
  "))
  ),
  
  sidebarLayout(
    sidebarPanel(
      verticalLayout(
        wellPanel(
          h3("小组件预设"),
          numericInput("nRows", "行数", value = 2, min = 1,max = 11),
          numericInput("nCols", "列数", value = 3, min = 1,max = 11),
          actionButton("assemb_button", "初始组件"),
          actionButton("reset_button", "重置已加载组件"),
        ),
        wellPanel(
          id = "addPanel",
          h3("小组件管理"),
          numericInput("Ammont", "数量", value = 1, min = 1,max = 11),
          actionButton("add_button", "加载组件"),

        ),
        wellPanel(
          h3("大容器"),
          numericInput("nRows2", "容器行数", value = 3, min = 2,max = 11),
          numericInput("nCols2", "容器列数", value = 4, min = 2,max = 11),
          actionButton("contains_button", "初始容器"),
          actionButton("add_button2", "确定容器"),
        ),
        wellPanel(
          id = "runPanel",
          h3("开始计算"),
          actionButton("run_button", "计算"),
          textOutput("solutionCount"),
          textOutput("runing_time"),
        ),
        wellPanel(
          id = "dispPanel",
          h3("展示"),
          numericInput("index", "第几个解", value = 1, min = 1),
          actionButton("disp_button", "展示"),
        ),
      )
    ),
  
 

    mainPanel(
      uiOutput("gridLayout"),
      hr(),
      h3("按钮状态："),
      uiOutput("btnStates"),
      hr(),
      uiOutput("gridLayout2"),
      hr(),
      h3("按钮状态："),
      uiOutput("btnStates2"),
      imageOutput("plotImage")
      

      
    )
  )
)