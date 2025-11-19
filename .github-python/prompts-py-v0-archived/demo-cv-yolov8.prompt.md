# 🚀 AI Engineering Prompt: End-to-End Computer Vision System (YOLOv8)

You are an expert AI software engineer and DevOps assistant.

Your goal is to **automatically create, verify, and run** a complete local computer vision project in Python that performs **real-time object detection using YOLOv8** — with zero manual steps from the user.

Follow these exact instructions:

---

## 1️⃣ PROJECT OBJECTIVE
Create a project that:
- Uses the webcam to detect and label real-world objects in real-time using **YOLOv8n** (nano variant - 3.2M parameters, optimized for speed).
- Automatically handles environment setup, installation, verification, and error handling.
- Saves detection results locally and provides a test mode for non-webcam verification.
- **Performance Targets**: 15+ FPS on CPU, 30+ FPS on GPU at 640×640 resolution.
- **Success Criteria**: Detects ≥3 objects with confidence >0.5 in test mode.

---

## 2️⃣ SETUP STEPS
1. Create a new folder called `vision_app`.
2. Inside, create these files and directories:

vision_app/
├── main.py
├── requirements.txt
├── .gitignore
├── utils/
│ └── verify_env.py
├── results/
└── logs/

3. Populate `requirements.txt` with:

ultralytics>=8.0.0
opencv-python>=4.8.0
torch>=2.0.0
torchvision>=0.15.0
torchaudio>=2.0.0
matplotlib>=3.7.0
pillow>=10.0.0

4. Create `.gitignore` with:

.venv/
__pycache__/
*.pyc
results/
logs/
*.pt
.DS_Store

5. Automatically create and activate a virtual environment (`python -m venv .venv && source .venv/bin/activate` for Unix or `.venv\Scripts\activate` for Windows).

6. Install all requirements via:

pip install -r requirements.txt


---

## 3️⃣ ENVIRONMENT VERIFICATION
In `utils/verify_env.py`, write code to:
- Check all dependencies can be imported.
- Check Python ≥ 3.9.
- Detect GPU availability via PyTorch.
- Verify webcam access (`cv2.VideoCapture(0)`) with permission handling:
  - On macOS: Detect permission denial and instruct user to enable in System Preferences
  - On Windows/Linux: Check device availability
- Verify model download capability (~6MB for yolov8n.pt).
- Check available disk space (minimum 500MB for results).
- Print clear pass/fail messages for each check with status indicators (✅/❌/⚠️).

If any test fails, print the exact resolution instructions (e.g., "Install OpenCV again using pip install opencv-python").

**Edge Cases to Handle**:
- Network connectivity for first-time model download
- Camera permissions denied (OS-specific instructions)
- Insufficient disk space
- Missing system libraries (Linux: libGL, libGLib)

---

## 4️⃣ MAIN APPLICATION LOGIC (`main.py`)
Create a Python script that:

1. Imports YOLOv8 from `ultralytics`.
2. Loads the pretrained model **`yolov8n.pt`** (nano variant - fastest option).
3. **Configuration Parameters** (use constants at top of file):
   - `CONFIDENCE_THRESHOLD = 0.5`
   - `INPUT_RESOLUTION = (640, 640)`
   - `TARGET_FPS = 30`
   - `MAX_SAVED_FRAMES = 5`
4. Opens webcam feed via OpenCV with error handling for permission denial.
5. Runs real-time object detection:
   - Draw bounding boxes with class labels and confidence scores
   - Display live FPS counter on frame
   - Show object count per frame
   - Filter detections by confidence threshold
   - Press `q` to exit safely, `s` to save current frame
6. **Metrics Logging**:
   - Log detection metrics to `logs/metrics.json`:
     - Timestamp
     - Objects detected per frame
     - Inference time (ms)
     - FPS achieved
     - Confidence scores
   - Generate summary statistics on exit
7. Save up to 5 sample detected frames into `results/` folder with timestamps.
8. Add `--test` argument:
   - Download and use this specific test image: `https://ultralytics.com/images/bus.jpg`
   - Run inference and verify ≥3 objects detected with confidence >0.5
   - Save annotated result to `results/test_output.jpg`
   - Print detailed test results (object counts, classes, confidence scores)
9. Print success message with summary when detection verified.

---

## 5️⃣ DOCUMENTATION
Generate a `README.md` file that includes:
- **Project Overview**
  - What it does
  - Key features
  - Performance characteristics
- **Installation & Setup Instructions**
  - Platform-specific notes (macOS camera permissions, Linux dependencies)
  - Virtual environment creation
  - Dependency installation
- **How to Run**
  - Test mode: `python main.py --test`
  - Real-time mode: `python main.py`
  - Configuration options
- **Hardware/OS Requirements**
  - Minimum: Python 3.9+, 4GB RAM, webcam
  - Recommended: Python 3.11+, 8GB RAM, CUDA GPU
  - OS-specific requirements
- **YOLOv8 Model Information**
  - Why YOLOv8n (nano) was chosen
  - Model variants comparison table (n, s, m, l, x)
  - Accuracy vs Speed tradeoffs
- **Configuration Parameters**
  - How to adjust confidence threshold
  - Resolution options
  - Class filtering examples
- **Common Errors & Fixes**
  - Camera permission issues by OS
  - CUDA/GPU setup problems
  - Model download failures
  - Import errors
- **Output Files**
  - Results folder structure
  - Metrics log format (JSON schema)
  - How to interpret logs

Include a section called **"How It Works Internally"** explaining:
- Flow between `verify_env.py` and `main.py`
- YOLOv8 architecture overview
- Inference pipeline (preprocessing → detection → postprocessing)
- NMS (Non-Maximum Suppression) handling

---

## 6️⃣ AUTOMATIC VERIFICATION AND SUMMARY
After setup:
- Run all checks in `verify_env.py`.
- Display detailed status report with three states:
  - ✅ **PASS**: All systems operational
  - ⚠️ **WARNING**: Non-critical issues (e.g., no GPU, running on CPU)
  - ❌ **FAIL**: Critical issues preventing execution
- If all critical checks pass, automatically execute `python main.py --test` once.
- **Test Mode Success Criteria**:
  - ≥3 objects detected in test image
  - All detections have confidence >0.5
  - Annotated image saved to `results/test_output.jpg`
  - Metrics logged to `logs/metrics.json`
- Summarize results with:
  - Total objects detected
  - Average confidence score
  - Inference time
  - System performance rating (Excellent/Good/Fair/Poor)
- Provide final run commands:

# For test mode (no webcam needed)
python main.py --test

# For live detection (requires webcam)
python main.py


---

## 7️⃣ PERFORMANCE OPTIMIZATIONS
**Required**:
- If CUDA GPU is available, enable `model.to('cuda')` and log GPU model name.
- If not, warn user and continue on CPU with performance expectations.
- Resize frames to exactly 640×640 for optimal YOLOv8n performance.
- Implement frame skipping if FPS drops below 10 (process every 2nd frame).

**Optional Enhancements** (mention in README):
- Class filtering: Allow user to detect only specific classes (e.g., only people and cars)
- Confidence threshold adjustment via command-line argument
- Video file input mode (process video files instead of webcam)
- Save detection results as video file
- Multi-stream support (multiple cameras)
- Custom model support (allow fine-tuned models)

---

## 8️⃣ DELIVERABLES
Provide the following in your response:

1. **Complete Code Files** (in separate Markdown code blocks):
   - `main.py` (well-commented, follows PEP 8)
   - `utils/verify_env.py`
   - `requirements.txt`
   - `.gitignore`
   - `README.md`

2. **Quick Start Instructions** (copy-paste ready commands)

3. **Verification Checklist**:
   - [ ] Virtual environment created
   - [ ] Dependencies installed
   - [ ] Environment checks passed
   - [ ] Test mode successful (≥3 objects detected)
   - [ ] Metrics logged correctly
   - [ ] Ready for live detection

The generated system must:
✅ Build automatically with clear error messages  
✅ Verify environment with OS-specific guidance  
✅ Run detection live with performance metrics  
✅ Handle errors gracefully (camera permissions, model download, disk space)  
✅ Be 100% local — no external API calls  
✅ Log metrics for performance analysis  
✅ Achieve performance targets (15+ FPS CPU, 30+ FPS GPU)  
✅ Follow Python best practices (type hints, docstrings, error handling)

---

## 9️⃣ CODE QUALITY REQUIREMENTS
- Use type hints for all functions
- Include docstrings (Google style)
- Implement proper exception handling with specific error messages
- Add logging with appropriate levels (INFO, WARNING, ERROR)
- Use context managers for resource management (camera, files)
- Follow PEP 8 style guidelines
- Include input validation for all user-provided parameters

---

