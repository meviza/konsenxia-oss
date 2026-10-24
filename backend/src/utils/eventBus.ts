import { EventEmitter } from 'events';
import { logger } from './logger';

class EventBus extends EventEmitter {
    constructor() {
        super();
        // Increase max listeners if needed
        this.setMaxListeners(20);
    }

    publish(eventName: string, payload: any) {
        logger.info(`[EventBus] Publishing event: ${eventName}`, { payloadId: payload?.id });
        this.emit(eventName, payload);
    }

    subscribe(eventName: string, handler: (payload: any) => void) {
        logger.info(`[EventBus] Subscribed to event: ${eventName}`);
        this.on(eventName, async (payload) => {
            try {
                await handler(payload);
            } catch (error) {
                logger.error(`[EventBus] Error handling event ${eventName}`, { error, payloadId: payload?.id });
            }
        });
    }
}

// Export a singleton instance
export const eventBus = new EventBus();

// Defined Event Constants
export const EVENTS = {
    CONSULTATION_CREATED: 'CONSULTATION_CREATED',
    CONSULTATION_UPDATED: 'CONSULTATION_UPDATED',
    AI_ANALYSIS_COMPLETED: 'AI_ANALYSIS_COMPLETED',
    DIAGNOSIS_VERIFIED: 'DIAGNOSIS_VERIFIED',
};
