📷 Image Blending using Color Balance and Alpha Masking
This project demonstrates a simple yet effective pipeline for blending an object image into a background scene using:

HSV-based alpha mask extraction

Radial Basis Function (RBF) based color balancing in LAB color space

Alpha blending for seamless integration

🔧 Features
🖼️ Object extraction using HSV thresholding (to separate object from white background)

🎨 Color matching between source and target images using RBF interpolation in LAB color space

🧠 RANSAC-based outlier rejection to improve control point robustness

🔀 Smooth and realistic blending using alpha compositing

🛠️ Files
blend_object_into_scene.m: Main script to run the full pipeline: loading images, generating alpha mask, color balancing, and blending.

color_balance_rbf.m: Core function that uses RBF interpolation with RANSAC filtering to adjust colors for better realism.

phone4.jpg: The object image to be blended (e.g., a mobile phone on white background).

source.jpg: The target scene image into which the object is blended.

📌 How It Works
Masking: Converts the object image to HSV and extracts the non-white object as a binary alpha mask.

Control Points: You define 3+ corresponding points in the object and background image.

Color Transfer: Uses those points to guide color correction using an RBF model in LAB color space.

Blending: Alpha values are used to softly blend the corrected object into the target scene.

▶️ How to Run
Place your images in the project folder:

Replace phone4.jpg with your object image

Replace source.jpg with your target background

In MATLAB, run:

matlab
Copy
Edit
blend_object_into_scene
The script will display:

The original object

The extracted alpha mask

The color-adjusted object

The final composite

💡 Example Use Cases
Virtual try-on (furniture, decor, phones)

AR mockups

Product placement in ads

Educational image processing demos

📁 Dependencies
MATLAB with Image Processing Toolbox

🧠 Credits
Color balancing inspired by RBF interpolation techniques in computer vision

LAB color space for perceptually uniform color adjustments

Simple RANSAC-based outlier rejection for robustness
