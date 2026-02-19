library(terra)
v <- vect("C:/Users/jiuponi/Documents/Oyo mapping/oyo_state.shp")

dec1 <- rast("C:/Users/jiuponi/Downloads/S2_Oyo_MSAVI_Dec2022.tif")
Dec_all <- crop(dec1, v)
Dec_all <- mask(Dec_all, v)
writeRaster(Dec_all,"C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Dec2022.tif")
dec2 <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/VI_Dec2022.tif")
decNDVI <- dec2$NDVI
decBSI <- dec2$BSI
decNDTI <- dec2$NDTI
decMSAVI <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Dec2022.tif")
dd11 <- project(decNDTI, novBSI_raster) 
decbsi1 <- crop(dd11, novBSI_raster)
decbsi1 <- mask(decbsi1,novBSI_raster)
writeRaster(decbsi1,"C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/Dec_Maize_NDTI_2022b.tif")
plot(decbsi1)

jan1 <- rast("C:/Users/jiuponi/Downloads/S2_Oyo_MSAVI_Jan2023.tif")
Jan_all <- crop(jan1, v)
Jan_all <- mask(Jan_all, v)
writeRaster(Jan_all,"C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Jan2023.tif")
jan2 <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/VI_Jan2023.tif")
janNDVI <- jan2$NDVI
janBSI <- jan2$BSI
janNDTI <- jan2$NDTI
janMSAVI <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Jan2023.tif")


feb1 <- rast("C:/Users/jiuponi/Downloads/S2_Oyo_MSAVI_Feb2023.tif")
Feb_all <- crop(feb1, v)
Feb_all <- mask(Feb_all, v)
writeRaster(Feb_all,"C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Feb2022.tif")
feb2 <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/VI_Feb2022.tif")
febNDVI <- feb2$NDVI
febBSI <- feb2$BSI
febNDTI <- feb2$NDTI
febMSAVI <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/MSAVI_Feb2022.tif")

  
mono <- vect("C:/Users/jiuponi/Documents/RF and CNN croptype map/RF Ensemble/Monocrop.shp")
Intercrop <- vect("C:/Users/jiuponi/Documents/RF and CNN croptype map/RF Ensemble/Intercrop.shp")
crs1 <- crs(v)

mono <- project(mono,crs1)
Intercrop <- project(Intercrop, crs1)


decNDTI_m <- extract(decNDTI,mono)
decNDTI_i <- extract(decNDTI,Intercrop)
decNDTI_i$Month <- "December"
decNDTI_m$Month <- "December"
decNDTI_m$Crop <- "Maize"
decNDTI_i$Crop <- "Maize/Cassava"
n_i <- nrow(decNDTI_i)
decNDTI_m_bal <- decNDTI_m[sample(1:nrow(decNDTI_m), n_i), ]
# Combine balanced dataset
decNDTI_i_m <- rbind(decNDTI_m_bal, decNDTI_i)


janNDTI_m <- extract(janNDTI,mono)
janNDTI_i <- extract(janNDTI,Intercrop)
janNDTI_i$Month <- "January"
janNDTI_m$Month <- "January"
janNDTI_m$Crop <- "Maize"
janNDTI_i$Crop <- "Maize/Cassava"
j_i <- nrow(janNDTI_i)
janNDTI_m_bal <- janNDTI_m[sample(1:nrow(janNDTI_m), j_i), ]
# Combine balanced dataset
janNDTI_i_m <- rbind(janNDTI_m_bal, janNDTI_i)

febNDTI_m <- extract(febNDTI,mono)
febNDTI_i <- extract(febNDTI,Intercrop)
febNDTI_i$Month <- "February"
febNDTI_m$Month <- "February"
febNDTI_m$Crop <- "Maize"
febNDTI_i$Crop <- "Maize/Cassava"
f_i <- nrow(febNDTI_i)
febNDTI_m_bal <- febNDTI_m[sample(1:nrow(febNDTI_m), f_i), ]
# Combine balanced dataset
febNDTI_i_m <- rbind(febNDTI_m_bal, febNDTI_i)

#combined_data <- rbind(novNDTI_m, novNDTI_i,decNDTI_m,decNDTI_i,janNDTI_m,janNDTI_i,febNDTI_m,febNDTI_i)
combined_data <- rbind(decNDTI_i_m,janNDTI_i_m,febNDTI_i_m)
#"November",
combined_data$Month <- factor(combined_data$Month, levels = c( "December", "January", "February"))
library(ggplot2)
ggplot(combined_data, aes(x = Month, y = NDTI, fill = Crop)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "NDTI Box Plot for Maize and Maize/Cassava",
       x = "Month",
       y = "NDTI") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  ylim(c(0, 0.7)) +  # Adjust BSI range if needed
  theme(axis.title = element_text(face = "bold"))

library(dplyr)
december_data <- combined_data %>% filter(Month == "December")

t.test(NDTI ~ Crop, data = december_data, var.equal = FALSE)  # Welch's t-test (default)

t.test(NDTI ~ Crop, data = december_data, var.equal = FALSE, conf.level = 0.99)

# Load required libraries
library(ggplot2)

# Create the boxplot
ggplot(december_data, aes(x = Crop, y = NDTI, fill = Crop)) +
  geom_boxplot(alpha = 0.7) +
  labs(title = "NDTI Distribution for Monocrop and Intercrop Fields (December)",
       x = "Crop Type",
       y = "NDTI") +
  theme_minimal() +
  scale_fill_manual(values = c("blue", "red")) + # Customize colors
  theme(axis.title = element_text(face = "bold"))


# Load the novNDTI raster
decNDTI_raster <- rast("C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/Dec_Maize_NDTI_2022b.tif")


# Compute median and standard deviation for Maize
maize_stats <- december_data %>% 
  filter(Crop == "Maize") %>% 
  summarize(median_NDTI = median(NDTI, na.rm = TRUE), 
            sd_NDTI = sd(NDTI, na.rm = TRUE))

# Compute mediam and standard deviation for Maize/Cassava (Intercrop)
maize_cassava_stats <- december_data %>% 
  filter(Crop == "Maize/Cassava") %>% 
  summarize(median_NDTI = median(NDTI, na.rm = TRUE), 
            sd_NDTI = sd(NDTI, na.rm = TRUE))


library(pROC)

roc_obj <- roc(december_data$Crop, december_data$NDTI)

auc(roc_obj)

coords(roc_obj, "best", ret="threshold", best.method="youden")


thr <- 0.1373987

pred <- ifelse(december_data$NDTI < thr,
               "Maize/Cassava",
               "Maize")

pred <- factor(pred, levels = c("Maize", "Maize/Cassava"))
true <- factor(december_data$Crop, levels = c("Maize", "Maize/Cassava"))

cm <- table(Pred = pred, True = true)
cm

# 1 = Monocrop, 2 = Intercrop
classified_raster <- ifel(is.na(decNDTI_raster), NA,
                          ifel(decNDTI_raster < thr, 2, 1))

classified_raster <- as.factor(classified_raster)
levels(classified_raster)[[1]] <- data.frame(
  ID = c(1, 2),
  category = c("Monocrop", "Intercrop")
)

freq_table <- freq(classified_raster)
percent_intercrop <- with(freq_table, count[value == "Intercrop"] / sum(count) * 100)

# Define colors
class_colors <- c("blue", "green")  # 1 = blue (Monocrop), 2 = green (Intercrop)
plot(classified_raster)

# Plot the classified raster
plot(classified_raster, col = class_colors, main = "Classified decNDTI Raster (1 = Monocrop, 2 = Intercrop)", 
     legend = FALSE)

# Add a legend
legend("topright", legend = c("Monocrop", "Intercrop"), fill = class_colors, border = "black")



writeRaster(classified_raster,
            "C:/Users/jiuponi/Documents/Oyo mapping/NDVI analysis/Vegetaion Indecies new/classified_DecNDTI.tif",
            overwrite = TRUE)
