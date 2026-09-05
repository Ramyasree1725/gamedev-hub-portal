import os
import zipfile
import sys

def zipdir(source_dir, output_zip):
    print(f"Creating ZIP archive: {output_zip}")
    print(f"Source Directory: {source_dir}")
    
    file_count = 0
    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, source_dir)
                zipf.write(file_path, arcname)
                file_count += 1
                
    print(f"Successfully zipped {file_count} files (including .git) into {output_zip}!")

if __name__ == '__main__':
    source = sys.argv[1] if len(sys.argv) > 1 else "."
    dest = sys.argv[2] if len(sys.argv) > 2 else "Submission_Repo.zip"
    zipdir(source, dest)
