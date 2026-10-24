import { Router, Request, Response } from 'express';
import { upload, FileService, FileMetadata } from '../services/file_service';
import admin from 'firebase-admin';
import path from 'path';

const router = Router();
const fileService = new FileService();
const db = admin.firestore();
const FILES_COLLECTION = 'medical_files';

// POST /upload — Upload a medical file
router.post('/upload', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Dosya bulunamadi' });
    }

    const { category = 'other', caseId, notes } = req.body;
    const userId = (req as any).userId || 'anonymous';

    // Generate thumbnail
    const thumbnailName = await fileService.generateThumbnail(
      req.file.path, req.file.filename
    );

    // Get image dimensions
    const dimensions = await fileService.getImageMetadata(req.file.path);

    const metadata: FileMetadata = {
      id: path.parse(req.file.filename).name,
      originalName: req.file.originalname,
      fileName: req.file.filename,
      mimeType: req.file.mimetype,
      size: req.file.size,
      category,
      thumbnailPath: thumbnailName || undefined,
      width: dimensions?.width,
      height: dimensions?.height,
      uploadedBy: userId,
      uploadedAt: new Date(),
      caseId: caseId || undefined,
      notes: notes || undefined,
    };

    // Save metadata to Firestore
    await db.collection(FILES_COLLECTION).doc(metadata.id).set({
      ...metadata,
      uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // If associated with a case, update case attachments
    if (caseId) {
      await db.collection('cases').doc(caseId).update({
        attachments: admin.firestore.FieldValue.arrayUnion([metadata.id]),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    res.json({
      success: true,
      file: {
        id: metadata.id,
        originalName: metadata.originalName,
        fileName: metadata.fileName,
        mimeType: metadata.mimeType,
        size: metadata.size,
        category: metadata.category,
        thumbnailUrl: thumbnailName ? `/api/v1/files/thumbnail/${thumbnailName}` : null,
        fileUrl: `/api/v1/files/download/${metadata.fileName}`,
        width: metadata.width,
        height: metadata.height,
      },
    });
  } catch (error: any) {
    console.error('Upload error:', error);
    res.status(500).json({ error: error.message || 'Yukleme hatasi' });
  }
});

// POST /upload-multiple — Upload multiple files
router.post('/upload-multiple', upload.array('files', 10), async (req: Request, res: Response) => {
  try {
    const files = req.files as Express.Multer.File[];
    if (!files || files.length === 0) {
      return res.status(400).json({ error: 'Dosya bulunamadi' });
    }

    const { category = 'other', caseId } = req.body;
    const userId = (req as any).userId || 'anonymous';

    const results = await Promise.all(
      files.map(async (file) => {
        const thumbnailName = await fileService.generateThumbnail(file.path, file.filename);
        const dimensions = await fileService.getImageMetadata(file.path);
        const id = path.parse(file.filename).name;

        const metadata: FileMetadata = {
          id,
          originalName: file.originalname,
          fileName: file.filename,
          mimeType: file.mimetype,
          size: file.size,
          category,
          thumbnailPath: thumbnailName || undefined,
          width: dimensions?.width,
          height: dimensions?.height,
          uploadedBy: userId,
          uploadedAt: new Date(),
          caseId: caseId || undefined,
        };

        await db.collection(FILES_COLLECTION).doc(id).set({
          ...metadata,
          uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (caseId) {
          await db.collection('cases').doc(caseId).update({
            attachments: admin.firestore.FieldValue.arrayUnion([id]),
          });
        }

        return {
          id,
          originalName: file.originalname,
          fileUrl: `/api/v1/files/download/${file.filename}`,
          thumbnailUrl: thumbnailName ? `/api/v1/files/thumbnail/${thumbnailName}` : null,
          mimeType: file.mimetype,
          size: file.size,
        };
      })
    );

    res.json({ success: true, files: results });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Yukleme hatasi' });
  }
});

// GET /case/:caseId — Get all files for a case
router.get('/case/:caseId', async (req: Request, res: Response) => {
  try {
    const { caseId } = req.params;
    const snapshot = await db
      .collection(FILES_COLLECTION)
      .where('caseId', '==', caseId)
      .orderBy('uploadedAt', 'desc')
      .get();

    const files = snapshot.docs.map((doc) => {
      const d = doc.data();
      return {
        id: doc.id,
        originalName: d.originalName,
        fileName: d.fileName,
        mimeType: d.mimeType,
        size: d.size,
        category: d.category,
        fileUrl: `/api/v1/files/download/${d.fileName}`,
        thumbnailUrl: d.thumbnailPath ? `/api/v1/files/thumbnail/${d.thumbnailPath}` : null,
        width: d.width,
        height: d.height,
        notes: d.notes,
        uploadedAt: d.uploadedAt?.toDate?.()?.toISOString() || null,
      };
    });

    res.json({ files });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// GET /download/:fileName — Serve file
router.get('/download/:fileName', (req: Request, res: Response) => {
  const filePath = path.join(__dirname, '../../uploads', req.params.fileName);
  res.sendFile(filePath);
});

// GET /thumbnail/:fileName — Serve thumbnail
router.get('/thumbnail/:fileName', (req: Request, res: Response) => {
  const filePath = path.join(__dirname, '../../uploads/thumbnails', req.params.fileName);
  res.sendFile(filePath);
});

// DELETE /:fileId — Delete a file
router.delete('/:fileId', async (req: Request, res: Response) => {
  try {
    const { fileId } = req.params;
    const doc = await db.collection(FILES_COLLECTION).doc(fileId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Dosya bulunamadi' });
    }

    const data = doc.data()!;
    await fileService.deleteFile(data.fileName, data.thumbnailPath);
    await db.collection(FILES_COLLECTION).doc(fileId).delete();

    // Remove from case attachments
    if (data.caseId) {
      await db.collection('cases').doc(data.caseId).update({
        attachments: admin.firestore.FieldValue.arrayRemove([fileId]),
      });
    }

    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
