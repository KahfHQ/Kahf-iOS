//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "TSAttachmentPointer.h"
#import "OWSBackupFragment.h"
#import "TSAttachmentStream.h"
#import <SignalServiceKit/MimeTypeUtil.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSAttachmentStream (TSAttachmentPointer)

- (CGSize)cachedMediaSize;

@end

#pragma mark -

@interface TSAttachmentPointer ()

// Optional property.  Only set for attachments which need "lazy backup restore."
@property (nonatomic, nullable) NSString *lazyRestoreFragmentId;

@end

#pragma mark -

@implementation TSAttachmentPointer

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    // A TSAttachmentPointer is a yet-to-be-downloaded attachment.
    // If this is an old TSAttachmentPointer from another session,
    // we know that it failed to complete before the session completed.
    if (![coder containsValueForKey:@"state"]) {
        _state = TSAttachmentPointerStateFailed;
    }

    if (_pointerType == TSAttachmentPointerTypeUnknown) {
        _pointerType = TSAttachmentPointerTypeIncoming;
    }

    return self;
}

- (instancetype)initWithServerId:(UInt64)serverId
                             key:(NSData *)key
                          digest:(nullable NSData *)digest
                       byteCount:(UInt32)byteCount
                     contentType:(NSString *)contentType
                  sourceFilename:(nullable NSString *)sourceFilename
                         caption:(nullable NSString *)caption
                  albumMessageId:(nullable NSString *)albumMessageId
                  attachmentType:(TSAttachmentType)attachmentType
                       mediaSize:(CGSize)mediaSize
                        blurHash:(nullable NSString *)blurHash
{
    self = [super initWithServerId:serverId
                     encryptionKey:key
                         byteCount:byteCount
                       contentType:contentType
                    sourceFilename:sourceFilename
                           caption:caption
                    albumMessageId:albumMessageId
                          blurHash:blurHash];
    if (!self) {
        return self;
    }

    _digest = digest;
    _state = TSAttachmentPointerStateEnqueued;
    self.attachmentType = attachmentType;
    _pointerType = TSAttachmentPointerTypeIncoming;
    _mediaSize = mediaSize;

    return self;
}

- (instancetype)initForRestoreWithAttachmentStream:(TSAttachmentStream *)attachmentStream
{
    OWSAssertDebug(attachmentStream);

    self = [super initForRestoreWithUniqueId:attachmentStream.uniqueId
                                 contentType:attachmentStream.contentType
                              sourceFilename:attachmentStream.sourceFilename
                                     caption:attachmentStream.caption
                              albumMessageId:attachmentStream.albumMessageId];
    if (!self) {
        return self;
    }

    _state = TSAttachmentPointerStateEnqueued;
    self.attachmentType = attachmentStream.attachmentType;
    _pointerType = TSAttachmentPointerTypeRestoring;
    _mediaSize = (attachmentStream.shouldHaveImageSize ? attachmentStream.cachedMediaSize : CGSizeZero);

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
                  albumMessageId:(nullable NSString *)albumMessageId
                  attachmentType:(TSAttachmentType)attachmentType
                        blurHash:(nullable NSString *)blurHash
                       byteCount:(unsigned int)byteCount
                         caption:(nullable NSString *)caption
                     contentType:(NSString *)contentType
                   encryptionKey:(nullable NSData *)encryptionKey
                        serverId:(unsigned long long)serverId
                  sourceFilename:(nullable NSString *)sourceFilename
                 uploadTimestamp:(unsigned long long)uploadTimestamp
                          digest:(nullable NSData *)digest
           lazyRestoreFragmentId:(nullable NSString *)lazyRestoreFragmentId
                       mediaSize:(CGSize)mediaSize
                     pointerType:(TSAttachmentPointerType)pointerType
                           state:(TSAttachmentPointerState)state
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
                    albumMessageId:albumMessageId
                    attachmentType:attachmentType
                          blurHash:blurHash
                         byteCount:byteCount
                           caption:caption
                       contentType:contentType
                     encryptionKey:encryptionKey
                          serverId:serverId
                    sourceFilename:sourceFilename
                   uploadTimestamp:uploadTimestamp];

    if (!self) {
        return self;
    }

    _digest = digest;
    _lazyRestoreFragmentId = lazyRestoreFragmentId;
    _mediaSize = mediaSize;
    _pointerType = pointerType;
    _state = state;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

+ (nullable TSAttachmentPointer *)attachmentPointerFromProto:(SSKProtoAttachmentPointer *)attachmentProto
                                                albumMessage:(nullable TSMessage *)albumMessage
{
    if (attachmentProto.id < 1) {
        OWSFailDebug(@"Invalid attachment id.");
        return nil;
    }
    if (attachmentProto.key.length < 1) {
        OWSFailDebug(@"Invalid attachment key.");
        return nil;
    }
    NSString *_Nullable fileName = attachmentProto.fileName;
    NSString *_Nullable contentType = attachmentProto.contentType;
    if (contentType.length < 1) {
        // Content type might not set if the sending client can't
        // infer a MIME type from the file extension.
        OWSLogWarn(@"Invalid attachment content type.");
        NSString *_Nullable fileExtension = [fileName pathExtension].lowercaseString;
        if (fileExtension.length > 0) {
            contentType = [MIMETypeUtil mimeTypeForFileExtension:fileExtension];
        }
        if (contentType.length < 1) {
            contentType = OWSMimeTypeApplicationOctetStream;
        }
    }

    // digest will be empty for old clients.
    NSData *_Nullable digest = attachmentProto.hasDigest ? attachmentProto.digest : nil;

    TSAttachmentType attachmentType = TSAttachmentTypeDefault;
    if ([attachmentProto hasFlags]) {
        UInt32 flags = attachmentProto.flags;
        if ((flags & (UInt32)SSKProtoAttachmentPointerFlagsVoiceMessage) > 0) {
            attachmentType = TSAttachmentTypeVoiceMessage;
        }
    }
    NSString *_Nullable caption;
    if (attachmentProto.hasCaption) {
        caption = attachmentProto.caption;
    }

    NSString *_Nullable albumMessageId;
    if (albumMessage != nil) {
        albumMessageId = albumMessage.uniqueId;
    }

    CGSize mediaSize = CGSizeZero;
    if (attachmentProto.hasWidth && attachmentProto.hasHeight && attachmentProto.width > 0
        && attachmentProto.height > 0) {
        mediaSize = CGSizeMake(attachmentProto.width, attachmentProto.height);
    }

    UInt64 serverId = attachmentProto.id;
    if (![SDS fitsInInt64:serverId]) {
        OWSFailDebug(@"Invalid server id.");
        return nil;
    }

    NSString *_Nullable blurHash;
    if (contentType.length > 0 && [MIMETypeUtil isVisualMedia:contentType] && attachmentProto.hasBlurHash) {
        blurHash = attachmentProto.blurHash;
        if (![BlurHash isValidBlurHash:blurHash]) {
            blurHash = nil;
        }
    }

    TSAttachmentPointer *pointer = [[TSAttachmentPointer alloc] initWithServerId:serverId
                                                                             key:attachmentProto.key
                                                                          digest:digest
                                                                       byteCount:attachmentProto.size
                                                                     contentType:contentType
                                                                  sourceFilename:fileName
                                                                         caption:caption
                                                                  albumMessageId:albumMessageId
                                                                  attachmentType:attachmentType
                                                                       mediaSize:mediaSize
                                                                        blurHash:blurHash];
    return pointer;
}

+ (NSArray<TSAttachmentPointer *> *)attachmentPointersFromProtos:
                                        (NSArray<SSKProtoAttachmentPointer *> *)attachmentProtos
                                                    albumMessage:(TSMessage *)albumMessage
{
    OWSAssertDebug(attachmentProtos);
    OWSAssertDebug(albumMessage);

    NSMutableArray *attachmentPointers = [NSMutableArray new];
    for (SSKProtoAttachmentPointer *attachmentProto in attachmentProtos) {
        TSAttachmentPointer *_Nullable attachmentPointer =
            [self attachmentPointerFromProto:attachmentProto albumMessage:albumMessage];
        if (attachmentPointer) {
            [attachmentPointers addObject:attachmentPointer];
        }
    }
    return [attachmentPointers copy];
}

- (BOOL)isDecimalNumberText:(NSString *)text
{
    return [text componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].count == 1;
}

- (void)upgradeFromAttachmentSchemaVersion:(NSUInteger)attachmentSchemaVersion
{
    // Legacy instances of TSAttachmentPointer apparently used the serverId as their
    // uniqueId.
    if (attachmentSchemaVersion < 2 && self.serverId == 0) {
        OWSAssertDebug([self isDecimalNumberText:self.uniqueId]);
        if ([self isDecimalNumberText:self.uniqueId]) {
            // For legacy instances, try to parse the serverId from the uniqueId.
            self.serverId = [self.uniqueId integerValue];
        } else {
            OWSLogError(@"invalid legacy attachment uniqueId: %@.", self.uniqueId);
        }
    }
}

- (nullable OWSBackupFragment *)lazyRestoreFragmentWithTransaction:(SDSAnyReadTransaction *)transaction
{
    if (!self.lazyRestoreFragmentId) {
        return nil;
    }
    OWSBackupFragment *_Nullable backupFragment = [OWSBackupFragment anyFetchWithUniqueId:self.lazyRestoreFragmentId
                                                                              transaction:transaction];
    OWSAssertDebug(backupFragment);
    return backupFragment;
}

#pragma mark - Update With... Methods

- (void)markForLazyRestoreWithFragment:(OWSBackupFragment *)lazyRestoreFragment
                           transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(lazyRestoreFragment);
    OWSAssertDebug(transaction);

    if (!lazyRestoreFragment.uniqueId) {
        // If metadata hasn't been saved yet, save now.
        [lazyRestoreFragment anyInsertWithTransaction:transaction];

        OWSAssertDebug(lazyRestoreFragment.uniqueId);
    }
    [self anyUpdateAttachmentPointerWithTransaction:transaction
                                              block:^(TSAttachmentPointer *attachmentPointer) {
                                                  [attachmentPointer
                                                      setLazyRestoreFragmentId:lazyRestoreFragment.uniqueId];
                                              }];
}

- (void)ydb_saveWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    [self checkForStreamOverwrite:transaction.asAnyRead];

    [super ydb_saveWithTransaction:transaction];
}

- (void)anyWillInsertWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyWillInsertWithTransaction:transaction];

    [self checkForStreamOverwrite:transaction];
}

- (void)anyWillUpdateWithTransaction:(SDSAnyWriteTransaction *)transaction
{
    [super anyWillUpdateWithTransaction:transaction];

    [self checkForStreamOverwrite:transaction];
}

- (void)checkForStreamOverwrite:(SDSAnyReadTransaction *)transaction
{
#ifdef DEBUG
    if (self.uniqueId.length > 0) {
        TSAttachment *_Nullable oldObject = [TSAttachment anyFetchWithUniqueId:self.uniqueId transaction:transaction];
        if ([oldObject isKindOfClass:[TSAttachmentStream class]]) {
            OWSFailDebug(@"We should never overwrite a TSAttachmentStream with a TSAttachmentPointer.");
        }
    } else {
        OWSFailDebug(@"Missing uniqueId.");
    }
#endif
}

@end

NS_ASSUME_NONNULL_END
