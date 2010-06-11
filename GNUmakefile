#
#	GNUmakefile
#
#       Compile the Pixen application
#


include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME=Pixen
#VERSION= 

#Pixen_SUBPROJECTS = KTMatrix

Pixen_APPLICATION_ICON=Pixen.tiff

Pixen_MAIN_MODEL_FILE = MainMenu

Pixen_OBJC_FILES = Constants.m\
InterpolatePoint.m\
NSArray_DeepMutableCopy.m\
NSBezierPath+PXRoundedRectangleAdditions.m\
NSColor+PXPaletteAdditions.m\
NSMutableArray+ReorderingAdditions.m\
OSACTReader.m\
OSACTWriter.m\
OSJASCPALReader.m\
OSJASCPALWriter.m\
OSPALReader.m\
OSPALWriter.m\
OSProgressPopup.m\
OSStackedView.m\
PXAboutController.m\
PXAboutPanel.m\
PXActionButton.m\
PXAnimatedGifExporter.m\
PXAnimation.m\
PXAnimationBackgroundView.m\
PXAnimationPreview.m\
PXAnimationView.m\
PXBackground.m\
PXBackgroundController.m\
PXBackgroundPreviewView.m\
PXBackgroundTableHeader.m\
PXBackgroundTemplateView.m\
PXBackgroundsPanel.m\
PXBicubicScaleAlgorithm.m\
PXBitmapExporter.m\
PXBitmapImporter.m\
PXBuiltinBackgroundTemplateView.m\
PXCanvas.m\
PXCanvasController.m\
PXCanvasController_EventHandling.m\
PXCanvasDocument.m\
PXCanvasPrintView.m\
PXCanvasResizePrompter.m\
PXCanvasResizeView.m\
PXCanvasView.m\
PXCanvasWindowController.m\
PXCanvasWindowController_IBActions.m\
PXCanvasWindowController_Toolbar.m\
PXCanvasWindowController_Zooming.m\
PXCanvas_ApplescriptAdditions.m\
PXCanvas_Archiving.m\
PXCanvas_Backgrounds.m\
PXCanvas_CopyPaste.m\
PXCanvas_Drawing.m\
PXCanvas_Grid.m\
PXCanvas_ImportingExporting.m\
PXCanvas_Layers.m\
PXCanvas_Modifying.m\
PXCanvas_Selection.m\
PXCel.m\
PXCheckeredBackground.m\
PXColorPicker.m\
PXColorPickerColorWellCell.m\
PXCrosshair.m\
PXDefaultBackgroundTemplateView.m\
PXDefaults.m\
PXDocumentController.m\
PXDuotoneBackground.m\
PXEllipseTool.m\
PXEllipseToolPropertiesView.m\
PXEmptyPropertiesView.m\
PXEraserTool.m\
PXEyedropperTool.m\
PXEyedropperToolPropertiesView.m\
PXFillTool.m\
PXFillToolPropertiesView.m\
PXFilmStripView.m\
PXGifExporter.m\
PXGifImporter.m\
PXGradientBuilderController.m\
PXGrid.m\
PXGridSettingsPrompter.m\
PXHotkeyFormatter.m\
PXIconExporter.m\
PXImage.m\
PXImageBackground.m\
PXImageSizePrompter.m\
PXImageView.m\
PXImage_old.m\
PXInfoPanelController.m\
PXJPEGSizePrompter.m\
PXLassoTool.m\
PXLayer.m\
PXLayerController.m\
PXLayerDetailsView.m\
PXLayerTableView.m\
PXLayerTextField.m\
PXLineTool.m\
PXLinearTool.m\
PXMagicWandTool.m\
PXModalColorPanel.m\
PXModalColorWell.m\
PXMonotoneBackground.m\
PXMoveTool.m\
PXNamePrompter.m\
PXNearestNeighborScaleAlgorithm.m\
PXNotifications.m\
PXNumericDrawingController.m\
PXPSDHandler.m\
PXPalette.m\
PXPaletteController.m\
PXPaletteEditorWindow.m\
PXPaletteEntryView.m\
PXPaletteExporter.m\
PXPaletteImporter.m\
PXPalettePanel.m\
PXPalettePanelPaletteView.m\
PXPaletteRestrictor.m\
PXPaletteSelector.m\
PXPaletteView.m\
PXPaletteViewScrollView.m\
PXPaletteViewSizeSelector.m\
PXPanelManager.m\
PXPattern.m\
PXPatternCell.m\
PXPatternEditorController.m\
PXPatternEditorView.m\
PXPencilTool.m\
PXPencilToolPropertiesView.m\
PXPixel.m\
PXPreferencesController.m\
PXPreviewBezelView.m\
PXPreviewController.m\
PXPreviewResizePrompter.m\
PXPreviewResizeSizeView.m\
PXRectangleTool.m\
PXRectangleToolPropertiesView.m\
PXRectangularSelectionTool.m\
PXRetroImage.m\
PXRetroLayer.m\
PXRetroPalette.m\
PXSavedPatternMatrix.m\
PXScale2xScaleAlgorithm.m\
PXScaleAlgorithm.m\
PXScaleController.m\
PXSequenceExportPrompter.m\
PXSlashyBackground.m\
PXSpriteSheetExporter.m\
PXTool.m\
PXToolButtonCell.m\
PXToolPaletteController.m\
PXToolPropertiesController.m\
PXToolPropertiesView.m\
PXToolSwitcher.m\
PXUserWarmer.m\
PXWelcomeController.m\
PXZoomTool.m\
PathUtilities.m\
RBSplitSubview.m\
RBSplitView.m\
SBCenteringClipView.m\
SubviewTableViewCell.m\
SubviewTableViewController.m\
TabletEvents.m\
ThreadWorker.m\
UKFeedbackProvider.m\
UKPrefsPanel.m\
UKUpdateChecker.m\
main.m\
\
PXBackgroundInfoView.m\
PXApplication.m\
PXAnimationWindowController.m\
PXAnimationDocument.m\
OSQTExporter.m\
NSString_DegreeString.m\
OSGradient.m\
OSLinearGradient.m\
OSRadialGradient.m\

Pixen_LANGUAGES = English
Pixen_RESOURCE_FILES  = *.png *.tiff *.pxi

Pixen_LOCALIZED_RESOURCE_FILES  = MainMenu.gorm\
PXDocument.gorm\
PXAbout.gorm\
PXBackgroundController.gorm\
PXColorPalette.gorm\
PXDiscoverPixen.gorm\
PXGradientBuilder.gorm\
PXGridSettingsPrompter.gorm\
PXImageSizePrompt.gorm\
PXInfoPanel.gorm\
PXLayerController.gorm\
PXNamePrompt.gorm\
PXPreview.gorm\
PXPreferences.gorm\
PXToolPalette.gorm\
PXMonotoneBackgroundConfigurator.gorm\
PXPencilToolPropertiesView.gorm \
PXRectangleToolPropertiesView.gorm \
PXEllipseToolPropertiesView.gorm \
PXBlankPropertiesView.gorm \
PXDuotoneBackgroundConfigurator.gorm \
PXImageBackgroundConfigurator.gorm \
PXToolProperties.gorm\
PXLayerDetailsView.gorm\
Localizable.strings\
Credits.html

Pixen_OBJCFLAGS += -Wno-import
#Pixen_OBJCFLAGS += -Wall 
#ADDITIONAL_INCLUDE_DIRS += -IKTMatrix/

include $(GNUSTEP_MAKEFILES)/application.make

