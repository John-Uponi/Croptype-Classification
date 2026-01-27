# 1. Reference Data Collection and Labeling

High-resolution reference data were collected in Oyo State, Nigeria, using a SenseFly eBee X fixed-wing UAV and a vehicle-mounted GoPro Hero 8 camera during September–October 2022, covering approximately 1,300 ha. The UAV captured approximately 50,000 multispectral and RGB images, georeferenced using onboard RTK/PPK positioning to achieve centimeter-level accuracy without ground control points (GCPs). Orthomosaic reflectance and RGB products were generated using standard photogrammetric workflows in eMotion and Pix4D.

To supplement UAV coverage, street-level imagery was collected at 2 frames per second and geotagged using the camera’s built-in GPS/IMU. Images were manually linked to nearby field parcels within ~10 m of the driven path. Crop and land-cover boundaries were digitized from both UAV and GoPro imagery, yielding 820 field polygons across six classes: cassava, maize, built-up/bare ground, forest, grassland/other crops, and water. These polygons served as spatially explicit training and validation units for model development.

# 2. Satellite Data Processing and Feature Extraction
Sentinel-1 SAR

Multi-temporal Sentinel-1 Ground Range Detected (GRD) data were acquired for July–November 2022. Scenes were preprocessed using the Sentinel Application Platform (SNAP v9.0.8) and Google Earth Engine (GEE), including:

Thermal noise removal

Radiometric calibration

Terrain correction

Dual-polarization backscatter (VV, VH) was aggregated into:

Biweekly means (first and second halves of each month)

Monthly means

Seasonal composite (August–October)

These features captured temporal variation in canopy structure and moisture dynamics.

Sentinel-2 Multispectral

Cloud-free Sentinel-2B Level-2 surface reflectance imagery from December 2022 was atmospherically corrected using Sen2Cor. Ten spectral bands were used:

10 m: B2 (Blue), B3 (Green), B4 (Red), B8 (NIR)

20 m (resampled to 10 m): B5–B7 (Red-edge), B8A (Narrow NIR), B11–B12 (SWIR)

All predictors were harmonized to a 10 m spatial resolution.

Raster Extraction and Data Cleaning

Raster values were extracted to a tabular format using R (v4.4.0). Listwise deletion was applied to screen for missing values (NA/NaN/Inf) across the combined Sentinel-1 and Sentinel-2 feature stack. No missing values were detected, confirming spatial consistency prior to model training.

# 3. Classification and Validation

A multiclass Random Forest classifier was trained using the ranger engine via caret::train in R. The model classified six land-cover classes using combined SAR and multispectral predictors.

Model Configuration

Trees: 500

Split rule: Gini

Cross-validation: 10-fold, repeated 3 times

Optimization metric: Overall accuracy

Feature selection per split (mtry): 21

Node size: 1

Class balancing: None applied (moderate class balance)

Preprocessing: Box-Cox transformation

Reproducibility: Fixed random seed

Spatial Validation Strategy

Training and test data were split at the polygon level (70/30) to prevent spatial leakage and ensure true spatial independence:

Training set: 572 polygons (~711,664 pixels)

Test set: 248 polygons (~213,512 pixels)

Although out-of-bag (OOB) accuracy was computed, final performance evaluation relied on the independent test set to avoid optimistic bias.

# 4. Intercropping Detection (Maize–Cassava)

To detect maize–cassava intercropping, a post-classification phenological approach was applied during the dry season (November 2022). This leveraged cassava’s continued photosynthetic activity after maize harvest.

Vegetation Indices

The following indices were computed for maize-classified pixels:

NDVI — Normalized Difference Vegetation Index

MSAVI — Modified Soil-Adjusted Vegetation Index

BSI — Bare Soil Index

NDTI — Normalized Difference Tillage Index

Threshold-Based Reclassification

Welch’s t-tests were used to compare monocropped and intercropped field distributions. A BSI threshold was defined as the midpoint between group means:

BSI < threshold → Intercropped maize–cassava

BSI ≥ threshold → Monocropped maize

This approach exploits phenological contrast rather than spectral unmixing, improving robustness in smallholder, heterogeneous farming systems.

#5. Software and Tools
Tool	Purpose
Google Earth Engine (GEE)	Cloud-based satellite data access and preprocessing
SNAP v9.0.8	Sentinel-1 and Sentinel-2 preprocessing
R v4.4.0 / RStudio 2024.04.2	Feature extraction, modeling, validation
Python 3.10.3	Data screening and preprocessing
Pix4D / eMotion	UAV photogrammetry and orthomosaic generation

# Reproducibility Notes

All spatial splits were performed at the polygon level to prevent spatial leakage

A fixed random seed was used for model training

Predictor stacks were screened for missing values prior to modeling

Vegetation indices for intercropping detection were computed post-classification and not used as RF predictors
