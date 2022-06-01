# DL-based-MultiFunctional-Synapse-Analysis-V1.0
**Keywords: synaptic analysis; electron microscope image; deep learning; synaptic ultrastructure** <br>
Zhang Chen Lab, Peking University/Capital Medical University

## Abstract
 A multifunctional synaptic analysis system based on several advanced deep learning models. The system achieved synapse counting in low-magnification EM images and synaptic ultrastructure analysis in high-magnification EM images. The synapse counting system based on ResNet18 and Faster R-CNN model accomplished an average precision (mAP) of 92.55%. For synaptic ultrastructure analysis, the Faster R-CNN model based on ResNet50 reached the mAP of 91.60%; the DeepLab v3+ model based on ResNet50 enabled high performance in presynaptic and postsynaptic membrane segmentation with a global accuracy of 0.9811; the Faster R-CNN model based on ResNet18 achieved the mAP of 91.41% for synaptic vesicle detection. 
 
 ## File description
 ***high-magnification-lite***: High-magnification module.  <br>
 <img src="high-magnification-lite/EM images_ResultsVisual/5-rescale.png" height="200px" width="auto"/>    <br>
 ***low-magnification-lite***: Low-magnification module.  <br>
 <img src="low-magnification-lite/EM images_AutoDetect/test_0124_AutoDetect-rescale.png" height="200px" width="auto"/>    <br>

## Run the system
**Please load data (EM images and pre-trined models) in BaiduDisk first:**   <br>
	Link: https://pan.baidu.com/s/1LKnO_B4rSShw0VtLWMjo8A    <br>
	Entercode: EMIM    <br>
run main.m files in *high-magnification-lite* and *low-magnification-lite*.
