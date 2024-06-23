#-------------------------------------------------------------------------------

# Load the necessary packages
library(readxl)
library(tidyverse)
library(patchwork)
library(gridExtra)
library(reshape2)

#-------------------------------------------------------------------------------

# Import the file with cell counts and delete the file names of images
df_rename <- read_excel("Ground Truth.xlsx")
df_rename$file_name <- NULL
names(df_rename)[names(df_rename) == 'human_counter_1'] <- 'Human 1'
names(df_rename)[names(df_rename) == 'human_counter_2'] <- 'Human 2'
names(df_rename)[names(df_rename) == 'ImageJ'] <- 'Fiji'

# Get list of column names
column_names <- colnames(df_rename)

# Import the file with cell counts and keep the file names of images
df_samples = read_excel("Ground Truth.xlsx")
names(df_samples)[names(df_samples) == 'human_counter_1'] <- 'Human 1'
names(df_samples)[names(df_samples) == 'human_counter_2'] <- 'Human 2'
names(df_samples)[names(df_samples) == 'ImageJ'] <- 'Fiji'

#-------------------------------------------------------------------------------

# Define a function to create and return a combined plot showing the counts of
# cells in each image
create_plots <- function(start_row, end_row) {
  
  # Pivot the dataframe to a longer format
  df_long <- df_samples[start_row:end_row,] %>%
    pivot_longer(cols = -file_name, names_to = "Counter", values_to = "Value")
  
  # Find the maximum value in the 'Value' column for setting y-axis limits
  max_y <- max(df_long$Value)
  
  # Create a list of plots, one for each 'file_name'
  plot_list <- df_long %>%
    group_by(file_name) %>%
    group_split() %>%
    map(~ ggplot(data = .x, aes(x = Counter, y = Value, fill = Counter)) +
          geom_bar(stat = "identity", position = "dodge") +
          geom_text(aes(label = Value), 
                    position = position_dodge(width = 0.9), 
                    vjust = 0.4,
                    angle = 90, hjust = 2) +
          scale_fill_brewer(palette = "Set1") +
          coord_cartesian(ylim = c(0, max_y)) +
          theme_minimal() +
          theme(axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.text.x = element_blank(),
                axis.ticks.x = element_blank()))
  
  # Combine all the individual plots into one combined plot
  combined_plot <- wrap_plots(plot_list, nrow = 1) +
    plot_layout(guides = 'collect') & 
    theme(legend.position = 'bottom')
  
  # Return the combined plot
  return(combined_plot)
}

# Determine the number of rows in the dataset
num_rows <- nrow(df_samples)

# Loop through the dataframe in chunks of 10 rows and create the plot for the current chunk
for (start_row in seq(1, num_rows, by = 10)) {
  end_row <- min(start_row + 9, num_rows)
  plot <- create_plots(start_row, end_row)
  print(plot)
}

#-------------------------------------------------------------------------------

# Prepare a list to store plots in
plots <- list()

# Loop through all pairs of columns to calculate differences
for (i in 1:(length(column_names) - 1)) {
  for (j in (i + 1):length(column_names)) {
    col1 <- column_names[i]
    col2 <- column_names[j]
    
    # Calculate differences
    differences <- df_rename[[col1]] - df_rename[[col2]]
    
    # Create a data frame for differences
    diff_df <- data.frame(differences)
    
    # Plot histogram of differences
    plot1 <- ggplot(diff_df, aes(x = differences)) +
      geom_histogram(aes(y = ..density..), bins = 10, fill = "blue", alpha = 0.7) +
      geom_density(color = "red", size = 1) +
      ggtitle(paste("Histogram of Differences:", col1, "-", col2)) +
      xlab("Difference in Counts") +
      ylab("") +
      theme_minimal()
    
    # Plot Q-Q plot of differences
    plot2 <- ggplot(diff_df, aes(sample = differences)) +
      stat_qq() +
      stat_qq_line(color = "red") +
      ggtitle(paste("Q-Q Plot of Differences:", col1, "-", col2)) +
      ylab("") +
      xlab("Theoretical Quantiles") +
      theme_minimal()
    
    # Add plots to the list
    plots[[length(plots) + 1]] <- plot1
    plots[[length(plots) + 1]] <- plot2
    
    # Perform Shapiro-Wilk test on differences
    shapiro_test <- shapiro.test(differences)
    cat(paste("Shapiro-Wilk test for differences (", col1, "-", col2, "): 
              p-value =", shapiro_test$p.value, "\n"))
  }
}

# Arrange and display plots in a grid
grid.arrange(grobs = plots, nrow = 6, ncol = 2)

#-------------------------------------------------------------------------------

# Define a function to perform the Wilcoxon signed-rank test
perform_wilcoxon_test <- function(column1, column2, col_name1, col_name2) {
  test_result <- wilcox.test(column1, column2, paired = TRUE, exact = FALSE)
  cat(paste("Wilcoxon signed-rank test between ", col_name1, "and", col_name2, ": 
              p-value =", test_result$p.value, "\n"))
}

# Loop through pairs of columns and perform the Wilcoxon signed-rank test
for (i in 1:(ncol(df_rename) - 1)) {
  for (j in (i + 1):ncol(df_rename)) {
    col_name1 <- column_names[i]
    col_name2 <- column_names[j]
    perform_wilcoxon_test(df_rename[[col_name1]], df_rename[[col_name2]], col_name1, col_name2)
  }
}

#-------------------------------------------------------------------------------

# Define a function to compute the Pearson correlation coefficient
compute_pearson_cor <- function(column1, column2, col_name1, col_name2) {
  test_result <- cor(column1, column2, method = 'pearson')
  cat(paste("Pearson correlation coefficient between ", col_name1, "and", col_name2, 
             "=", test_result, "\n"))
}

# Loop through pairs of columns and compute the Pearson correlation coefficient
for (i in 1:(ncol(df_rename) - 1)) {
  for (j in (i + 1):ncol(df_rename)) {
    col_name1 <- column_names[i]
    col_name2 <- column_names[j]
    compute_pearson_cor(df_rename[[col_name1]], df_rename[[col_name2]], col_name1, col_name2)
  }
}

#-------------------------------------------------------------------------------

# Conduct the Friedman test and print the result
friedman_result <- friedman.test(as.matrix(df_rename))
print(friedman_result)

# Reshape the data for pairwise comparisons
melted_data <- melt(df_rename)

# Perform pairwise Wilcoxon test with Bonferroni correction and print the result
post_hoc <- pairwise.wilcox.test(melted_data$value, melted_data$variable, 
                                 p.adjust.method = "bonferroni",
                                 paired = TRUE)
print(post_hoc)

