import os
import shutil


def copy_file(srcPath, dstPath, artifactName):
    """Copies an artifact from a source to specified destination"""
    create_dir(dstPath)

    srcFile = os.path.join(srcPath, artifactName)
    dstFile = os.path.join(dstPath, artifactName)
    shutil.copy(srcFile, dstFile)


def delete_file(srcPath, artifactName):
    srcFile = os.path.join(srcPath, artifactName)
    if os.path.exists(srcFile):
        os.remove(srcFile)


def create_dir(dirPath):
    """Create directory helper"""
    if not os.path.exists(dirPath):
        os.makedirs(dirPath)
    return


def delete_dir(dirPath):
    """Delete directory helper"""
    if os.path.exists(dirPath):
        shutil.rmtree(dirPath)
    return
