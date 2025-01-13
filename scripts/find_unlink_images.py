import os
import re

def get_all_images_from_directory(directory):
    """获取指定目录下所有图片的文件名"""
    image_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.svg'}
    images = set()
    for root, _, files in os.walk(directory):
        for file in files:
            if any(file.lower().endswith(ext) for ext in image_extensions):
                images.add(file.lower())

    return images

def get_all_image_references_from_markdown(directory):
    """从指定目录下的所有Markdown文件中提取图片引用"""
    image_references = set()
    image_pattern = re.compile(r'!\[.*?\]\(\{\{site\.static\}\}/images/([^\)]+)\)')
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    matches = image_pattern.findall(content)
                    image_references.update(matches)
    
    return image_references

def find_unlinked_and_missing_images(images, references):
    """找到未被引用的图片和引用但缺失的图片"""
    unlinked_images = images - references
    missing_images = references - images
    return unlinked_images, missing_images

def main():

    current_file_path = os.path.abspath(__file__)
    current_directory = os.path.dirname(current_file_path)
    parent_directory = os.path.dirname(current_directory)
    images_dir = os.path.join(parent_directory, 'images')
    posts_dir = os.path.join(parent_directory, '_posts')

    # 获取所有图片文件名
    images = get_all_images_from_directory(images_dir)
    
    # 提取所有Markdown文件中的图片引用
    references = get_all_image_references_from_markdown(posts_dir)

    # 找到未被引用的图片和引用但缺失的图片
    unlinked_images, missing_images = find_unlinked_and_missing_images(images, references)

    # 输出未被引用的图片
    print("未被引用的图片:")
    for image in sorted(unlinked_images):
        print(image)
    
    # 输出引用但缺失的图片
    print("\n引用但缺失的图片:")
    for image in sorted(missing_images):
        print(image)

if __name__ == "__main__":
    main()