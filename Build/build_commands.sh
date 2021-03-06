#!/bin/sh
BIN_DIR="bin"
SRC_DIR="$BIN_DIR/Sources"

# csharp
ES="Entitas"
CG="Entitas.CodeGenerator"
MIG="Entitas.Migration"
CG_TR="Entitas.CodeGenerator.TypeReflection"
ESU="Entitas.Unity"

ESU_ASSETS="$ESU/Assets"

collect_sources() {
  echo "Collecting sources..."

  rm -rf $BIN_DIR
  mkdir $BIN_DIR $SRC_DIR $SRC_DIR/$ESU

  cp -r {"$ES/$ES","$MIG/$MIG"} $SRC_DIR
  cp -r "$ESU_ASSETS/$ES/Unity/" $SRC_DIR/$ESU
  find "./$SRC_DIR" -name "*.meta" -type f -delete

  header_meta="Editor/EntitasHeader.png.meta"
  cp "$ESU_ASSETS/$ES/Unity/$header_meta" "$SRC_DIR/$ESU/$header_meta"

  entity_icon_meta="Editor/EntitasEntityHierarchyIcon.png.meta"
  entityError_icon_meta="Editor/EntitasEntityErrorHierarchyIcon.png.meta"
  pool_icon_meta="Editor/EntitasPoolHierarchyIcon.png.meta"
  poolError_icon_meta="Editor/EntitasPoolErrorHierarchyIcon.png.meta"
  systems_icon_meta="Editor/EntitasSystemsHierarchyIcon.png.meta"
  cp "$ESU_ASSETS/$ES/Unity/VisualDebugging/$entity_icon_meta" "$SRC_DIR/$ESU/VisualDebugging/$entity_icon_meta"
  cp "$ESU_ASSETS/$ES/Unity/VisualDebugging/$entityError_icon_meta" "$SRC_DIR/$ESU/VisualDebugging/$entityError_icon_meta"
  cp "$ESU_ASSETS/$ES/Unity/VisualDebugging/$pool_icon_meta" "$SRC_DIR/$ESU/VisualDebugging/$pool_icon_meta"
  cp "$ESU_ASSETS/$ES/Unity/VisualDebugging/$poolError_icon_meta" "$SRC_DIR/$ESU/VisualDebugging/$poolError_icon_meta"
  cp "$ESU_ASSETS/$ES/Unity/VisualDebugging/$systems_icon_meta" "$SRC_DIR/$ESU/VisualDebugging/$systems_icon_meta"

  migration_header_meta="Editor/EntitasMigrationHeader.png.meta"
  cp "$ESU_ASSETS/$ES/Unity/Migration/$migration_header_meta" "$SRC_DIR/$ESU/Migration/$migration_header_meta"

  echo "Collecting sources done."
}

update_project_dependencies() {
  echo "Updating project dependencies..."

  ESU_LIBS_DIR="$ESU_ASSETS/Libraries"

  rm -rf $ESU_LIBS_DIR
  mkdir $ESU_LIBS_DIR

  cp -r $SRC_DIR/{$ES,$MIG} $ESU_LIBS_DIR

  echo "Updating project dependencies done."
}

generateProjectFiles() {
  echo "Generating project files..."
  PWD=$(pwd)

  # Unity bug: https://support.unity3d.com/hc/en-us/requests/36273
  # Fixed in 5.3.4p1
  /Applications/Unity/Unity.app/Contents/MacOS/Unity -quit -batchmode -logfile -projectPath "$PWD/$ESU/Assets/../" -executeMethod Commands.GenerateProjectFiles
  echo "  SKIPPING"

  echo "Generating project files done."
}

build() {
  echo "Building..."
  xbuild /target:Clean /property:Configuration=Release Entitas.sln
  xbuild /property:Configuration=Release Entitas.sln
  echo "Building done."
}

runTests() {
  mono Tests/Libraries/NSpec/NSpecRunner.exe Tests/bin/Release/Tests.dll
}

collect_misc_files() {
  echo "Collecting misc files..."

  cp "$MIG/bin/Release/Entitas.Migration.exe" "$SRC_DIR/MigrationAssistant.exe"
  cp README.md "$SRC_DIR/README.md"
  cp RELEASE_NOTES.md "$SRC_DIR/RELEASE_NOTES.md"
  cp EntitasUpgradeGuide.md "$SRC_DIR/EntitasUpgradeGuide.md"
  cp LICENSE.txt "$SRC_DIR/LICENSE.txt"

  echo "Collecting misc files done."
}

create_zip() {
  echo "Creating zip files..."

  TMP_DIR="$BIN_DIR/tmp"

  echo "Creating Entitas-CSharp.zip..."
  mkdir $TMP_DIR
  cp -r $SRC_DIR/$ES $TMP_DIR
  cp "$SRC_DIR/"* $TMP_DIR || true

  pushd $TMP_DIR > /dev/null
    zip -rq ../Entitas-CSharp.zip ./
  popd > /dev/null
  rm -rf $TMP_DIR

  echo "Creating Entitas-Unity.zip..."
  mkdir $TMP_DIR
  cp -r "$SRC_DIR/"* $TMP_DIR || true

  tmp_editor_dir="$TMP_DIR/Editor"
  mkdir $tmp_editor_dir
  mv "$TMP_DIR/Entitas/CodeGenerator/"* $tmp_editor_dir
  mv {"$tmp_editor_dir/Attributes",$tmp_editor_dir} "$TMP_DIR/Entitas/CodeGenerator"

  mkdir "$TMP_DIR/$ES/Migration/"
  mv "$TMP_DIR/$MIG/" "$TMP_DIR/$ES/Migration/Editor/"

  mv "$TMP_DIR/$ESU/" "$TMP_DIR/$ES/Unity/"

  pushd $TMP_DIR > /dev/null
    zip -rq ../Entitas-Unity.zip ./
  popd > /dev/null
  rm -rf $TMP_DIR

  echo "Creating zip files done."
}

create_tree_overview() {
  echo "Creating tree overview..."
  tree -I 'bin|obj|Library|Libraries|*Tests|Readme|ProjectSettings|Temp|Examples|*.csproj|*.meta|*.sln|*.userprefs|*.properties' --noreport -d > tree.txt
  tree -I 'bin|obj|Library|Libraries|*Tests|Readme|ProjectSettings|Temp|Examples|*.csproj|*.meta|*.sln|*.userprefs|*.properties' --noreport --dirsfirst >> tree.txt
  echo "Creating tree overview done."
}
