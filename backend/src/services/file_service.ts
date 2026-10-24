import multer from 'multer';
import sharp from 'sharp';
import path from 'path';
import fs from 'fs';
import { v4 as uuidv4 } from 'uuid';

export interface FileMetadata {
  id: string;
  originalName: string;
  fileName: string;
  mimeType: string;
  size: number;
  category: 'lab_result' | 'xray' | 'ct' | 'mri' | 'ultrasound' | 'ecg' | 'pathology' | 'other';
  thumbnailPath?: string;
  width?: number;
  height?: number;
  uploadedBy: string;
  uploadedAt: Date;
  caseId?: string;
  notes?: string;
}

const UPLOAD_DIR = path.join(__dirname, '../../uploads');
const THUMB_DIR = path.join(UPLOAD_DIR, 'thumbnails');

// Ensure directories exist
[UPLOAD_DIR, THUMB_DIR].forEach(dir => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

// Multer config
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  },
});

export const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB max
  fileFilter: (req, file, cb) => {
    const allowed = [
      'image/jpeg', 'image/png', 'image/webp', 'image/gif',
      'application/pdf',
      'application/dicom', 'application/octet-stream', // DICOM
    ];
    if (allowed.includes(file.mimetype) || file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Desteklenmeyen dosya formati'));
    }
  },
});

export class FileService {
  // Generate thumbnail for images
  async generateThumbnail(filePath: string, fileName: string): Promise<string | null> {
    try {
      const ext = path.extname(fileName).toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.webp'].includes(ext)) return null;

      const thumbName = `thumb_${fileName}`;
      const thumbPath = path.join(THUMB_DIR, thumbName);

      await sharp(filePath)
        .resize(300, 300, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 80 })
        .toFile(thumbPath);

      return thumbName;
    } catch (e) {
      console.error('Thumbnail generation failed:', e);
      return null;
    }
  }

  // Get image dimensions
  async getImageMetadata(filePath: string): Promise<{ width: number; height: number } | null> {
    try {
      const metadata = await sharp(filePath).metadata();
      if (metadata.width && metadata.height) {
        return { width: metadata.width, height: metadata.height };
      }
      return null;
    } catch {
      return null;
    }
  }

  // Delete file and thumbnail
  async deleteFile(fileName: string, thumbnailName?: string): Promise<void> {
    const filePath = path.join(UPLOAD_DIR, fileName);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

    if (thumbnailName) {
      const thumbPath = path.join(THUMB_DIR, thumbnailName);
      if (fs.existsSync(thumbPath)) fs.unlinkSync(thumbPath);
    }
  }
}
