allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use projectDirectory as the base to avoid self-referencing the property
val newBuildDir = rootProject.layout.projectDirectory.dir("../../build")
// Set the root project's build directory to ../../build (no circular reference)
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // Each subproject builds into ../../build/<moduleName>
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(project.name))
    // Keep evaluation order consistent with app module
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
