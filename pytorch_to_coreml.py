from models.with_mobilenet import PoseEstimationWithMobileNet
from torchvision import transforms
import torch
from PIL import Image
from modules.load_state import load_state
from torch import nn
import argparse
from onnx import onnx_pb
from onnx_coreml import convert


def load_image(filename, size=None):
    img = Image.open(filename)
    if size is not None:
        img = img.resize((size, size), Image.ANTIALIAS)
    return img

class ImgWrapNet(nn.Module):
    """Add a layer of the normalization to the neural network"""
    def __init__(self, checkpoint_path, scale=256.):
        super().__init__()
        self.scale = scale

        pose_model = PoseEstimationWithMobileNet()
        state_dict = torch.load(checkpoint_path)
        load_state(pose_model, state_dict)
        self.pose_model = pose_model
        
    def forward(self, x):
        x = (x+(-128)) / self.scale
        x = self.pose_model(x)
        return x

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--checkpoint-path', type=str, default='checkpoints/checkpoint_iter_370000.pth', help='path to the checkpoint')
    parser.add_argument('-o', '--onnx-output', type=str, default='pose_{}.onnx', help='name of output model in ONNX format')
    parser.add_argument('-m', '--mlmodel-output', type=str, default='pose_{}.mlmodel', help='name of output model in CoreML format')
    parser.add_argument('-i', '--image-path', type=str, default='data/preview.jpg', help='path to the image')
    parser.add_argument('-s', '--shape', type=int, default=368, help='width and height of the input image')
    args = parser.parse_args()

    assert args.onnx_output.endswith('.onnx'), "Export model file should end with .onnx"

    # prepare the input image
    content_file = args.image_path
    content_image = load_image(content_file, 368)
    content_transform = transforms.Compose([
        transforms.ToTensor(),
    ])
    content_image = content_transform(content_image)
    content_image = content_image.unsqueeze(0)

    # convert to onnx
    model = ImgWrapNet(args.checkpoint_path)
    onnx_output = args.onnx_output.format(args.shape)
    torch.onnx.export(model, 
                      content_image, 
                      onnx_output,
                      verbose=True,
                      export_params=True,
                      input_names=['input_image'], 
                      output_names=['heat_map_1', 'paf_1', 'heat_map_2', 'paf_2'])

    # convert to CoreML
    mlmodel_out = args.mlmodel_output.format(args.shape)
    with open(onnx_output, 'rb') as onnx_model:
        model_proto = onnx_pb.ModelProto()
        model_proto.ParseFromString(onnx_model.read())
        coreml_model = convert(model_proto, 
                               image_input_names=['input_image'],)
        coreml_model.save(mlmodel_out)
