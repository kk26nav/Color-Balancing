
# 📷 Image Blending using Color Balance and Alpha Masking

This project demonstrates a simple yet effective pipeline for **blending an object image into a background scene** using:

- 🎯 HSV-based alpha mask extraction
- 🎨 Radial Basis Function (RBF) based color balancing in LAB color space
- ✨ Alpha blending for seamless integration

---

## 🔧 Features

- 🖼️ **Object extraction** using HSV thresholding (to separate object from white background)
- 🧪 **Color matching** using RBF interpolation in LAB color space
- 🧠 **RANSAC-based outlier rejection** for robust control point filtering
- 🌈 **Smooth and realistic blending** using alpha compositing

---

## 📁 File Overview

| File                  | Description |
|-----------------------|-------------|
| `blend_object_into_scene.m` | Main script to run the complete blending pipeline |
| `color_balance_rbf.m`       | RBF-based color balancing with RANSAC support |
| `phone4.jpg`                | Object image to blend (e.g., phone on white background) |
| `source.jpg`                | Background scene image |

---

## 🚀 How It Works

1. **Masking**  
   Converts the object image to HSV color space and extracts a binary alpha mask to isolate the object from a white background.

2. **Control Points**  
   You define 3+ corresponding control points between the object and background images.

3. **Color Transfer**  
   Uses Radial Basis Function (RBF) interpolation in LAB space to match the object's color profile to the background, using RANSAC to reject outliers.

4. **Alpha Blending**  
   Blends the object into the background using the alpha mask for soft transitions.

---

## ▶️ Running the Code

1. Ensure your images are placed in the same directory:
   - Replace `phone4.jpg` with your object image.
   - Replace `source.jpg` with your background scene.

2. Open MATLAB and run:
   ```matlab
   blend_object_into_scene
   ```

3. The script will show:
   - The original object
   - The alpha mask
   - The color-balanced object
   - The final composite image

---

## 🧠 Use Cases

- Product placement in marketing designs
- AR content generation and virtual try-ons
- Educational image processing demos
- Custom collages and graphics design

---

## 📦 Requirements

- MATLAB R2020 or newer (recommended)
- Image Processing Toolbox

---

## 📸 Example Output

| Step                  | Image |
|-----------------------|-------|
| Original Object       | 🖼️ `phone4.jpg` |
| Extracted Alpha Mask  | 🔲 Binary mask of the object |
| Color Balanced Object | 🎨 Adjusted for background lighting |
| Final Composite       | 🌌 Object blended into `source.jpg` |

---

## ✍️ Author

**Naveen Kumaran**  
B.Tech ECE, NIT Warangal  
Feel free to fork or contribute!

---

## 📜 License

This project is open-source and available under the MIT License.
